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

package org.apache.shardingsphere.db.protocol.firebird.packet.command.admin.info;

import io.netty.buffer.ByteBuf;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.apache.shardingsphere.db.protocol.firebird.packet.command.FirebirdCommandPacket;
import org.apache.shardingsphere.db.protocol.firebird.payload.FirebirdPacketPayload;

import java.util.ArrayList;
import java.util.List;

/**
 * Unsupported command packet for PostgreSQL.
 */
@RequiredArgsConstructor
@Getter
public final class FirebirdDatabaseInfoPacket extends FirebirdCommandPacket {

    private final int handle;

    private final int incarnation;

    private final List<Integer> infoItems = new ArrayList<>();

    private final int maxLength;

    public FirebirdDatabaseInfoPacket(FirebirdPacketPayload payload) {
        payload.skipReserved(4);
        handle = payload.readInt4();
        incarnation = payload.readInt4();
        parseInfo(payload.readBuffer());
        maxLength = payload.readInt4();
    }

    private void parseInfo(ByteBuf buffer) {
        while (buffer.isReadable()) {
            infoItems.add((int) buffer.readByte());
        }
    }

    @Override
    protected void write(final FirebirdPacketPayload payload) {}
}
