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

package org.apache.shardingsphere.proxy.frontend.firebird.command;

import lombok.AccessLevel;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.FirebirdCommandPacket;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.FirebirdCommandPacketType;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.query.info.FirebirdInfoPacket;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.query.statement.FirebirdAllocateStatementPacket;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.query.statement.FirebirdExecuteStatementPacket;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.query.statement.FirebirdPrepareStatementPacket;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.query.transaction.FirebirdCommitTransactionPacket;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.query.transaction.FirebirdRollbackTransactionPacket;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.query.transaction.FirebirdStartTransactionPacket;
import org.apache.shardingsphere.proxy.backend.session.ConnectionSession;
import org.apache.shardingsphere.proxy.frontend.command.executor.CommandExecutor;
import org.apache.shardingsphere.proxy.frontend.firebird.command.admin.FirebirdUnsupportedCommandExecutor;
import org.apache.shardingsphere.proxy.frontend.firebird.command.query.info.FirebirdDatabaseInfoExecutor;
import org.apache.shardingsphere.proxy.frontend.firebird.command.query.info.FirebirdSQLInfoExecutor;
import org.apache.shardingsphere.proxy.frontend.firebird.command.query.statement.FirebirdAllocateStatementCommandExecutor;
import org.apache.shardingsphere.proxy.frontend.firebird.command.query.statement.FirebirdExecuteStatementCommandExecutor;
import org.apache.shardingsphere.proxy.frontend.firebird.command.query.statement.FirebirdPrepareStatementCommandExecutor;
import org.apache.shardingsphere.proxy.frontend.firebird.command.query.transaction.FirebirdCommitTransactionCommandExecutor;
import org.apache.shardingsphere.proxy.frontend.firebird.command.query.transaction.FirebirdRollbackTransactionCommandExecutor;
import org.apache.shardingsphere.proxy.frontend.firebird.command.query.transaction.FirebirdStartTransactionCommandExecutor;

import java.sql.SQLException;

/**
 * Command executor factory for Firebird.
 */
@NoArgsConstructor(access = AccessLevel.PRIVATE)
@Slf4j
public final class FirebirdCommandExecutorFactory {
    
    /**
     * Create new instance of command executor.
     *
     * @param commandPacketType command packet type for PostgreSQL
     * @param commandPacket command packet for PostgreSQL
     * @param connectionSession connection session
     * @return created instance
     * @throws SQLException SQL exception
     */
    public static CommandExecutor newInstance(final FirebirdCommandPacketType commandPacketType, final FirebirdCommandPacket commandPacket,
                                              final ConnectionSession connectionSession) throws SQLException {
        switch (commandPacketType) {
            case OP_INFO_DATABASE:
                return new FirebirdDatabaseInfoExecutor((FirebirdInfoPacket) commandPacket, connectionSession);
            case OP_TRANSACTION:
                return new FirebirdStartTransactionCommandExecutor((FirebirdStartTransactionPacket) commandPacket, connectionSession);
            case OP_ALLOCATE_STATEMENT:
                return new FirebirdAllocateStatementCommandExecutor((FirebirdAllocateStatementPacket) commandPacket, connectionSession);
            case OP_PREPARE_STATEMENT:
                return new FirebirdPrepareStatementCommandExecutor((FirebirdPrepareStatementPacket) commandPacket, connectionSession);
            case OP_EXECUTE:
                return new FirebirdExecuteStatementCommandExecutor((FirebirdExecuteStatementPacket) commandPacket, connectionSession);
            case OP_INFO_SQL:
                return new FirebirdSQLInfoExecutor((FirebirdInfoPacket) commandPacket, connectionSession);
            case OP_COMMIT:
                return new FirebirdCommitTransactionCommandExecutor((FirebirdCommitTransactionPacket) commandPacket, connectionSession);
            case OP_ROLLBACK:
                return new FirebirdRollbackTransactionCommandExecutor((FirebirdRollbackTransactionPacket) commandPacket, connectionSession);
            default:
                return new FirebirdUnsupportedCommandExecutor();
        }
    }
}
