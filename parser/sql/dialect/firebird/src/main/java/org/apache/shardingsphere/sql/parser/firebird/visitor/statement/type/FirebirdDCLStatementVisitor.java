/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.shardingsphere.sql.parser.firebird.visitor.statement.type;

import org.apache.shardingsphere.sql.parser.api.ASTNode;
import org.apache.shardingsphere.sql.parser.api.visitor.statement.type.DCLStatementVisitor;
import org.apache.shardingsphere.sql.parser.autogen.FirebirdStatementParser.GrantContext;
import org.apache.shardingsphere.sql.parser.autogen.FirebirdStatementParser.RevokeContext;
import org.apache.shardingsphere.sql.parser.sql.common.segment.generic.table.SimpleTableSegment;
import org.apache.shardingsphere.sql.parser.sql.dialect.statement.firebird.dcl.FirebirdGrantStatement;
import org.apache.shardingsphere.sql.parser.sql.dialect.statement.firebird.dcl.FirebirdRevokeStatement;
import org.apache.shardingsphere.sql.parser.firebird.visitor.statement.FirebirdStatementVisitor;

/**
 * DCL statement visitor for Firebird.
 */
public final class FirebirdDCLStatementVisitor extends FirebirdStatementVisitor implements DCLStatementVisitor {
    
    @Override
    public ASTNode visitGrant(final GrantContext ctx) {
        FirebirdGrantStatement result = new FirebirdGrantStatement();
        if (null != ctx.privilegeClause()) {
            result.getTables().add((SimpleTableSegment) visit(ctx.privilegeClause().onObjectClause().privilegeLevel().tableName()));
        }
        return result;
    }
    
    @Override
    public ASTNode visitRevoke(final RevokeContext ctx) {
        FirebirdRevokeStatement result = new FirebirdRevokeStatement();
        if (null != ctx.privilegeClause()) {
            result.getTables().add((SimpleTableSegment) visit(ctx.privilegeClause().onObjectClause().privilegeLevel().tableName()));
        }
        return result;
    }
}
