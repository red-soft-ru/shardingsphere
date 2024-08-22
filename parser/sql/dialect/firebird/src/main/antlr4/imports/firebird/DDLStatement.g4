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

createDomain
    : CREATE DOMAIN domainName AS? dataType defaultClause? notNullClause? checkClause? characterSetClause?
    ;

defaultClause
    : DEFAULT defaultValue?
    ;

notNullClause
    : NOT NULL
    ;

checkClause
    : CHECK LP_ predicate RP_
    ;

characterSetClause
    : CHARACTER SET characterSetName collateClause?
    ;
    
createCollation
    : CREATE COLLATION collationName FOR characterSetName fromCollationClause? paddingClause? caseSensitivityClause? accentSensitivityClause? attributeClause?
    ;

fromCollationClause
    : FROM baseSortName | FROM EXTERNAL LP_ STRING_ RP_
    ;

paddingClause
    : NO PAD | PAD SPACE
    ;

caseSensitivityClause
    : CASE SENSITIVE | CASE INSENSITIVE
    ;

accentSensitivityClause
    : ACCENT SENSITIVE | ACCENT INSENSITIVE
    ;

attributeClause
    : attributeCollation (SEMI_ attributeCollation)*
    ;

alterTable
    : ALTER TABLE tableName alterDefinitionClause
    ;

alterDomain
    : ALTER DOMAIN domainName toTableClause? defaultClause? notNullAlterDomainClause? constraintClause? typeClause?
    ;

toTableClause
    : TO tableName
    ;
    
alterSequence
    : ALTER SEQUENCE tableName sequenceRestartClause? sequenceIncrementClause?
    ;

defaultClause
    : (SET DEFAULT defaultValue | DROP DEFAULT)
    ;

notNullAlterDomainClause
    : (SET | DROP) NOT NULL
    ;

constraintClause
    : (ADD CONSTRAINT? CHECK LP_ predicate RP_ | DROP CONSTRAINT)
    ;

typeClause
    : TYPE dataType (CHARACTER SET literals (COLLATE sortOrder)?)?
    ;

dropTable
    : DROP TABLE tableNames dropBehaviour
    ;

createFunction
    : CREATE FUNCTION functionName
      inputArgumentClause?
      RETURNS typeDescriptionArgument
      collateClause?
      DETERMINISTIC?
      (
          EXTERNAL NAME externalModuleName ENGINE engineName
      |
          (SQL SECURITY (DEFINER | INVOKER))?
          AS
          declarationClause?
          BEGIN
              statementBlock
          END
      )
    ;


statementBlock
    : (statement SEMI_)*
    ;

statement
    : select
    | insert
    | update
    | delete
    | return
    ;

declarationClause
    : declaration (COMMA_ declaration)*
    ;

declaration
    : localVariableDeclaration
    | cursorDeclaration
    | procedureDeclaration
    | functioneDeclaration
    ;

localVariableDeclaration
    : DECLARE VARIABLE? (
    localVariableDeclarationName typeDescriptionArgument
    (NOT NULL)?
    collateClause?
    ((EQ_ | DEFAULT) defaultValue)?
    | cursorName CURSOR FOR LP_ select RP_
    )
    ;

cursorDeclaration
    :  DECLARE VARIABLE? cursorName
    CURSOR FOR (SCROLL | NO SCROLL)? LP_ select RP_
    ;

procedureDeclaration
    : PROCEDURE procedureName inputArgumentClause? (RETURNS inputArgumentClause)?
    ;

functioneDeclaration
    : FUNCTION functionName inputArgumentClause? RETURNS typeDescriptionArgument collateClause? DETERMINISTIC?
    ;

inputArgument
    : descriptionArgument ((EQ_ | DEFAULT) defaultValue)?
    ;

inputArgumentClause
    : LP_ inputArgument (COMMA_ inputArgument)* RP_
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

sequenceRestartClause
    : RESTART (WITH bitExpr)?
    ;

sequenceIncrementClause
    : INCREMENT BY? NUMBER_
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
    : modifyColumn (TO tableName
                  | POSITION expr
                  | TYPE (dataType | domainName)
                  | SET DEFAULT defaultValue
                  | DROP DEFAULT
                  | SET NOT NULL
                  | DROP NOT NULL
                  | (TYPE dataType)? (GENERATED ALWAYS AS | COMPUTED BY?) LP_ expr RP_
                  | RESTART (WITH NUMBER_)?
                  )
    ;

modifyColumn
    : ALTER COLUMN? columnName
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

return
    : RETURN expr
    ;