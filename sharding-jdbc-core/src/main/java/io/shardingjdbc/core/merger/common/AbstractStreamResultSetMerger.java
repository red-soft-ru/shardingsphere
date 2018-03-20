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

package io.shardingjdbc.core.merger.common;

import io.shardingjdbc.core.merger.ResultSetMerger;
import io.shardingjdbc.core.merger.ResultSetMergerInput;
import lombok.Setter;

import java.io.InputStream;
import java.sql.SQLException;
import java.util.Calendar;

/**
 * 流式归并结果集.
 *
 * @author thor zhangliang
 */
@Setter
public abstract class AbstractStreamResultSetMerger implements ResultSetMerger {
    
    private ResultSetMergerInput currentResultSetMergerInput;
    
    private boolean wasNull;
    
    protected ResultSetMergerInput getCurrentResultSetMergerInput() throws SQLException {
        if (null == currentResultSetMergerInput) {
            throw new SQLException("Current ResultSet is null, ResultSet perhaps end of next.");
        }
        return currentResultSetMergerInput;
    }
    
    @Override
    public Object getValue(final int columnIndex, final Class<?> type) throws SQLException {
        Object result = getCurrentResultSetMergerInput().getValue(columnIndex, type);
        wasNull = getCurrentResultSetMergerInput().wasNull();
        return result;
    }
    
    @Override
    public Object getValue(final String columnLabel, final Class<?> type) throws SQLException {
        Object result = getCurrentResultSetMergerInput().getValue(columnLabel, type);
        wasNull = getCurrentResultSetMergerInput().wasNull();
        return result;
    }
    
    @Override
    public Object getCalendarValue(final int columnIndex, final Class<?> type, final Calendar calendar) throws SQLException {
        Object result = getCurrentResultSetMergerInput().getCalendarValue(columnIndex, type, calendar);
        wasNull = getCurrentResultSetMergerInput().wasNull();
        return result;
    }
    
    @Override
    public Object getCalendarValue(final String columnLabel, final Class<?> type, final Calendar calendar) throws SQLException {
        Object result = getCurrentResultSetMergerInput().getCalendarValue(columnLabel, type, calendar);
        wasNull = getCurrentResultSetMergerInput().wasNull();
        return result;
    }
    
    @SuppressWarnings("deprecation")
    @Override
    public InputStream getInputStream(final int columnIndex, final String type) throws SQLException {
        InputStream result = getCurrentResultSetMergerInput().getInputStream(columnIndex, type);
        wasNull = getCurrentResultSetMergerInput().wasNull();
        return result;
    }
    
    @SuppressWarnings("deprecation")
    @Override
    public InputStream getInputStream(final String columnLabel, final String type) throws SQLException {
        InputStream result = getCurrentResultSetMergerInput().getInputStream(columnLabel, type);
        wasNull = getCurrentResultSetMergerInput().wasNull();
        return result;
    }
    
    @Override
    public boolean wasNull() {
        return wasNull;
    }
}
