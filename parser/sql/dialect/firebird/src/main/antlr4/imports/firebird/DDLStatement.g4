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

grammar DDLStatement;

import DMLStatement;

createTable
    : CREATE createTemporaryTable? TABLE tableName createDefinitionClause sqlSecurity?
    ;

alterTable
    : ALTER TABLE tableName alterDefinitionClause
    ;

alterSequence
    : ALTER SEQUENCE tableName alterSequenceClause?
    ;

dropTable
    : DROP TABLE tableNames dropBehaviour
    ;

createDatabase
    : CREATE SCHEMA schemaName createDatabaseSpecification_*
    ;

dropDatabase
    : DROP SCHEMA schemaName dropBehaviour
    ;

createView
    : CREATE VIEW viewName (LP_ identifier (COMMA_ identifier)* RP_)?
      AS select
      (WITH (CASCADED | LOCAL)? CHECK OPTION)?
    ;

dropView
    : DROP VIEW viewName dropBehaviour
    ;

createTemporaryTable
    : GLOBAL TEMPORARY
    ;

sqlSecurity
    : SQL SECURITY (DEFINER | INVOKER)
    ;

createDefinitionClause
    : LP_ createDefinition (COMMA_ createDefinition)* RP_
    ;

alterSequenceClause
    : RESTART (WITH bitExpr)?
    | INCREMENT BY? NUMBER_
    ;

createDatabaseSpecification_
    : DEFAULT CHARACTER SET EQ_? characterSetName
    ;

createDefinition
    : columnDefinition | constraintDefinition | checkConstraintDefinition
    ;

columnDefinition
    : columnName dataType dataTypeOption*
    ;

dataTypeOption
    : primaryKey usingDefinition?
    | UNIQUE usingDefinition?
    | NOT? NULL
    | collateClause
    | checkConstraintDefinition
    | referenceDefinition
    | DEFAULT (literals | expr)
    | STRING_
    ;

checkConstraintDefinition
    : (CONSTRAINT ignoredIdentifier?)? CHECK expr
    ;

referenceDefinition
    : REFERENCES tableName columnNames? usingDefinition? (ON (UPDATE | DELETE) referenceOption)*
    ;

referenceOption
    : CASCADE | SET NULL | NO ACTION | SET DEFAULT
    ;

usingDefinition
    : USING (ASC(ENDING)? | DESC(ENDING)?)? INDEX identifier
    ;

constraintDefinition
    : (CONSTRAINT constraintName?)? (primaryKeyOption | uniqueOption | foreignKeyOption)
    ;

primaryKeyOption
    : primaryKey columnNames usingDefinition?
    ;

primaryKey
    : PRIMARY KEY
    ;

uniqueOption
    : UNIQUE columnNames usingDefinition?
    ;

foreignKeyOption
    : FOREIGN KEY columnNames referenceDefinition
    ;

createLikeClause
    : LP_? LIKE tableName RP_?
    ;


alterDefinitionClause
    : addColumnSpecification
    | modifyColumnSpecification
    | dropColumnSpecification
    | addConstraintSpecification
    | dropConstraintSpecification
    ;

addColumnSpecification
    : ADD COLUMN? columnDefinition
    ;

modifyColumnSpecification
    : ALTER COLUMN? columnDefinition
    ;

dropColumnSpecification
    : DROP COLUMN? columnName
    ;

addConstraintSpecification
    : ADD constraintDefinition
    ;

dropConstraintSpecification
    : DROP constraintDefinition
    ;
