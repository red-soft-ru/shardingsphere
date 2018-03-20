/*
 * Copyright 1999-2015 dangdang.com.
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * </p>
 */

package io.shardingjdbc.core.merger;

import io.shardingjdbc.core.constant.DatabaseType;
import io.shardingjdbc.core.merger.groupby.GroupByMemoryResultSetMerger;
import io.shardingjdbc.core.merger.groupby.GroupByStreamResultSetMerger;
import io.shardingjdbc.core.merger.iterator.IteratorStreamResultSetMerger;
import io.shardingjdbc.core.merger.orderby.OrderByStreamResultSetMerger;
import io.shardingjdbc.core.merger.pagination.LimitDecoratorResultSetMerger;
import io.shardingjdbc.core.merger.pagination.RowNumberDecoratorResultSetMerger;
import io.shardingjdbc.core.merger.pagination.TopAndRowNumberDecoratorResultSetMerger;
import io.shardingjdbc.core.parsing.parser.context.limit.Limit;
import io.shardingjdbc.core.parsing.parser.sql.dql.select.SelectStatement;
import io.shardingjdbc.core.util.SQLUtil;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * DQL result set merge engine.
 *
 * @author zhangliang
 */
public final class DQLMergeEngine implements MergeEngine {
    
    private final List<ResultSetMergerInput> resultSetMergerInputs;
    
    private final SelectStatement selectStatement;
    
    private final Map<String, Integer> columnLabelIndexMap;
    
    public DQLMergeEngine(final List<ResultSetMergerInput> resultSetMergerInputs, final SelectStatement selectStatement) throws SQLException {
        this.resultSetMergerInputs = resultSetMergerInputs;
        this.selectStatement = selectStatement;
        columnLabelIndexMap = getColumnLabelIndexMap(resultSetMergerInputs.get(0));
    }
    
    private Map<String, Integer> getColumnLabelIndexMap(final ResultSetMergerInput resultSetMergerInput) throws SQLException {
        Map<String, Integer> result = new TreeMap<>(String.CASE_INSENSITIVE_ORDER);
        for (int i = 1; i <= resultSetMergerInput.getColumnCount(); i++) {
            result.put(SQLUtil.getExactlyValue(resultSetMergerInput.getColumnLabel(i)), i);
        }
        return result;
    }
    
    @Override
    public ResultSetMerger merge() throws SQLException {
        selectStatement.setIndexForItems(columnLabelIndexMap);
        return decorate(build());
    }
    
    private ResultSetMerger build() throws SQLException {
        if (!selectStatement.getGroupByItems().isEmpty() || !selectStatement.getAggregationSelectItems().isEmpty()) {
            if (selectStatement.isSameGroupByAndOrderByItems()) {
                return new GroupByStreamResultSetMerger(columnLabelIndexMap, resultSetMergerInputs, selectStatement);
            } else {
                return new GroupByMemoryResultSetMerger(columnLabelIndexMap, resultSetMergerInputs, selectStatement);
            }
        }
        if (!selectStatement.getOrderByItems().isEmpty()) {
            return new OrderByStreamResultSetMerger(resultSetMergerInputs, selectStatement.getOrderByItems());
        }
        return new IteratorStreamResultSetMerger(resultSetMergerInputs);
    }
    
    private ResultSetMerger decorate(final ResultSetMerger resultSetMerger) throws SQLException {
        Limit limit = selectStatement.getLimit();
        if (null == limit) {
            return resultSetMerger;
        }
        if (DatabaseType.MySQL == limit.getDatabaseType() || DatabaseType.PostgreSQL == limit.getDatabaseType() || DatabaseType.H2 == limit.getDatabaseType()) {
            return new LimitDecoratorResultSetMerger(resultSetMerger, selectStatement.getLimit());
        }
        if (DatabaseType.Oracle == limit.getDatabaseType()) {
            return new RowNumberDecoratorResultSetMerger(resultSetMerger, selectStatement.getLimit());
        }
        if (DatabaseType.SQLServer == limit.getDatabaseType()) {
            return new TopAndRowNumberDecoratorResultSetMerger(resultSetMerger, selectStatement.getLimit());
        }
        return resultSetMerger;
    }
}
