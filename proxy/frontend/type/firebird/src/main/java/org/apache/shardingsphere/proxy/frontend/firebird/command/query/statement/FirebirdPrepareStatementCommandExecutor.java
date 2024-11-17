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

package org.apache.shardingsphere.proxy.frontend.firebird.command.query.statement;

import io.netty.buffer.ByteBuf;
import lombok.RequiredArgsConstructor;
import org.apache.shardingsphere.db.protocol.firebird.exception.FirebirdProtocolException;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.query.binary.statement.FirebirdPrepareStatementPacket;
import org.apache.shardingsphere.db.protocol.firebird.packet.generic.FirebirdGenericResponsePacket;
import org.apache.shardingsphere.db.protocol.packet.DatabasePacket;
import org.apache.shardingsphere.infra.binder.context.statement.SQLStatementContext;
import org.apache.shardingsphere.infra.binder.engine.SQLBindEngine;
import org.apache.shardingsphere.infra.database.core.type.DatabaseType;
import org.apache.shardingsphere.infra.spi.type.typed.TypedSPILoader;
import org.apache.shardingsphere.mode.metadata.MetaDataContexts;
import org.apache.shardingsphere.parser.rule.SQLParserRule;
import org.apache.shardingsphere.proxy.backend.context.ProxyContext;
import org.apache.shardingsphere.proxy.backend.session.ConnectionSession;
import org.apache.shardingsphere.proxy.frontend.command.executor.CommandExecutor;
import org.apache.shardingsphere.proxy.frontend.firebird.command.query.FirebirdServerPreparedStatement;
import org.apache.shardingsphere.proxy.frontend.firebird.command.query.transaction.FirebirdTransactionIdGenerator;
import org.apache.shardingsphere.sql.parser.sql.common.statement.SQLStatement;
import org.apache.shardingsphere.sql.parser.sql.common.statement.ddl.DDLStatement;
import org.apache.shardingsphere.sql.parser.sql.common.statement.dml.DeleteStatement;
import org.apache.shardingsphere.sql.parser.sql.common.statement.dml.InsertStatement;
import org.apache.shardingsphere.sql.parser.sql.common.statement.dml.SelectStatement;
import org.apache.shardingsphere.sql.parser.sql.common.statement.dml.UpdateStatement;
import org.apache.shardingsphere.sql.parser.sql.common.statement.tcl.CommitStatement;
import org.apache.shardingsphere.sql.parser.sql.common.statement.tcl.RollbackStatement;
import org.apache.shardingsphere.sql.parser.sql.common.statement.tcl.SavepointStatement;
import org.apache.shardingsphere.sql.parser.sql.common.statement.tcl.StartTransactionStatement;
import org.firebirdsql.gds.ISCConstants;

import java.sql.SQLException;
import java.util.*;

import static io.netty.buffer.Unpooled.buffer;

/**
 * Firebird prepare transaction command executor
 */
@RequiredArgsConstructor
public final class FirebirdPrepareStatementCommandExecutor implements CommandExecutor {

    private final FirebirdPrepareStatementPacket packet;
    private final ConnectionSession connectionSession;

    @Override
    public Collection<DatabasePacket> execute() throws SQLException {
        MetaDataContexts metaDataContexts = ProxyContext.getInstance().getContextManager().getMetaDataContexts();
        SQLParserRule sqlParserRule = metaDataContexts.getMetaData().getGlobalRuleMetaData().getSingleRule(SQLParserRule.class);
        DatabaseType databaseType = TypedSPILoader.getService(DatabaseType.class, "Firebird");
        SQLStatement sqlStatement = sqlParserRule.getSQLParserEngine(databaseType).parse(packet.getSQL(), true);
        SQLStatementContext sqlStatementContext = new SQLBindEngine(metaDataContexts.getMetaData(),
                connectionSession.getDefaultDatabaseName(), packet.getHintValueContext()).bind(sqlStatement, Collections.emptyList());
        int statementId;
        if (packet.isValidStatementHandle()) {
            statementId = packet.getStatementId();
        } else {
            int transactionId = FirebirdTransactionIdGenerator.getInstance().getTransactionId(connectionSession.getConnectionId());
            statementId = FirebirdStatementIdGenerator.getInstance().getStatementId(transactionId);
        }
        FirebirdServerPreparedStatement serverPreparedStatement = new FirebirdServerPreparedStatement(packet.getSQL(), sqlStatementContext, packet.getHintValueContext());
        connectionSession.getServerPreparedStatementRegistry().addPreparedStatement(statementId, serverPreparedStatement);
        return createResponse(sqlStatementContext);
    }

    private Collection<DatabasePacket> createResponse(final SQLStatementContext sqlStatementContext) {
        ByteBuf data = buffer(packet.getMaxLength());
        for (int i = 0; i < packet.getInfoItems().size(); i++) {
            switch (packet.getInfoItems().get(i)) {
                case ISCConstants.isc_info_sql_stmt_type:
                    data.writeByte(ISCConstants.isc_info_sql_stmt_type);
                    data.writeShortLE(4);
                    data.writeIntLE(getFirebirdStatementType(sqlStatementContext.getSqlStatement()));
                    break;
                case ISCConstants.isc_info_sql_select:
                    data.writeByte(ISCConstants.isc_info_sql_select);
                    i = processDescribe(sqlStatementContext, i, data);
                    break;
                case ISCConstants.isc_info_sql_bind:
                    data.writeByte(ISCConstants.isc_info_sql_bind);
                    i = processDescribe(sqlStatementContext, i, data);
                    break;
                default:
                    throw new FirebirdProtocolException("Unknown statement info request type %d", packet.getInfoItems().get(i));
            }
        }
        data.writeByte(1); //isc_info_end
    return Collections.singleton(new FirebirdGenericResponsePacket().setData(data.capacity(data.writerIndex()).array()));
    }

    private int getFirebirdStatementType(final SQLStatement statement) {
        if (statement instanceof SelectStatement) {
            return ISCConstants.isc_info_sql_stmt_select;
        }
        if (statement instanceof InsertStatement) {
            return ISCConstants.isc_info_sql_stmt_insert;
        }
        if (statement instanceof UpdateStatement) {
            return ISCConstants.isc_info_sql_stmt_update;
        }
        if (statement instanceof DeleteStatement) {
            return ISCConstants.isc_info_sql_stmt_delete;
        }
        if (statement instanceof DDLStatement) {
            return ISCConstants.isc_info_sql_stmt_ddl;
        }
        if (statement instanceof StartTransactionStatement) {
            return ISCConstants.isc_info_sql_stmt_start_trans;
        }
        if (statement instanceof CommitStatement) {
            return ISCConstants.isc_info_sql_stmt_commit;
        }
        if (statement instanceof RollbackStatement) {
            return ISCConstants.isc_info_sql_stmt_rollback;
        }
        if (statement instanceof SavepointStatement) {
            return ISCConstants.isc_info_sql_stmt_savepoint;
        }
        return 0;
    }

    private int processDescribe(SQLStatementContext sqlStatementContext, int idx, ByteBuf buffer) {
        for (int i = ++idx; i < packet.getInfoItems().size(); i++) {
            switch (packet.getInfoItems().get(i)) {
                case ISCConstants.isc_info_sql_describe_vars:
                    buffer.writeByte(ISCConstants.isc_info_sql_describe_vars);
                    break;
                case ISCConstants.isc_info_sql_sqlda_seq:
                case ISCConstants.isc_info_sql_type:
                case ISCConstants.isc_info_sql_sub_type:
                case ISCConstants.isc_info_sql_scale:
                case ISCConstants.isc_info_sql_length:
                case ISCConstants.isc_info_sql_field:
                case ISCConstants.isc_info_sql_alias:
                case ISCConstants.isc_info_sql_relation:
                case ISCConstants.isc_info_sql_relation_alias:
                case ISCConstants.isc_info_sql_owner:
                    //TODO process describe types
                    break;
                case ISCConstants.isc_info_sql_describe_end:
                    buffer.writeShortLE(4);
                    buffer.writeIntLE(0);
                    return i;
                default:
                    throw new FirebirdProtocolException("Unknown statement info request type %d", packet.getInfoItems().get(i));
            }
        }
        return 0;
    }
}
