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

grammar DMLStatement;

import BaseRule;

insert
    : INSERT INTO? tableName (insertValuesClause | insertSelectClause)
    ;

insertValuesClause
    : columnNames? (VALUES | VALUE) assignmentValues (COMMA_ assignmentValues)*
    ;

insertSelectClause
    : columnNames? select
    ;

update
    : UPDATE tableReferences setAssignmentsClause whereClause?
    ;

assignment
    : columnName EQ_ VALUES? LP_? assignmentValue RP_?
    ;

setAssignmentsClause
    : SET assignment (COMMA_ assignment)*
    ;

assignmentValues
    : LP_ assignmentValue (COMMA_ assignmentValue)* RP_
    | LP_ RP_
    ;

assignmentValue
    : expr | DEFAULT | blobValue
    ;

blobValue
    : STRING_
    ;

delete
    : DELETE singleTableClause whereClause?
    ;

singleTableClause
    : FROM tableName (AS? alias)?
    ;

select
    : withClause? combineClause
    ;

combineClause
    : selectClause (UNION (DISTINCT | ALL)? selectClause)*
    ;

selectClause
    : SELECT selectSpecification* projections fromClause? whereClause? groupByClause? havingClause? orderByClause?
    ;


selectSpecification
    : duplicateSpecification
    ;

duplicateSpecification
    : ALL | DISTINCT
    ;

projections
    : (unqualifiedShorthand | projection) (COMMA_ projection)*
    ;

projection
    : (columnName | expr) (AS? alias)? | qualifiedShorthand
    ;

alias
    : identifier | STRING_
    ;

unqualifiedShorthand
    : ASTERISK_
    ;

qualifiedShorthand
    : identifier DOT_ASTERISK_
    ;

fromClause
    : FROM tableReferences joinedTable?
    ;

tableReferences
    : escapedTableReference (COMMA_ escapedTableReference)*
    ;

escapedTableReference
    : tableReference | LBE_ tableReference RBE_
    ;

tableReference
    : tableFactor joinedTable*
    ;

tableFactor
    : tableName (AS? alias)? | subquery (AS? alias)? columnNames? | LP_ tableReferences RP_
    ;

joinedTable
    : ((INNER | CROSS)? JOIN) tableFactor joinSpecification?
    | (LEFT | RIGHT | FULL) OUTER? JOIN tableFactor joinSpecification
    | NATURAL (INNER | (LEFT | RIGHT | FULL) (OUTER?))? JOIN tableFactor
    ;

joinSpecification
    : ON expr | USING columnNames
    ;

whereClause
    : WHERE (expr | CURRENT OF cursorName)
    ;

groupByClause
    : GROUP BY orderByItem (COMMA_ orderByItem)*
    ;

havingClause
    : HAVING expr
    ;

subquery
    : LP_ (withClause? combineClause) RP_
    ;

withClause
    : WITH RECURSIVE? cteClause (COMMA_ cteClause)*
    ;

cteClause
    : identifier (LP_ columnNames RP_)? AS subquery
    ;

