# Audit Logging

For db audit logs, the following approach is used

- Application Logging

## Application Audit Logging

Application Audit Logging is implemented to fulfill and enable extended audit log functionalities for the SSI Credential Issuer.

In the implementation the possibility of pgAudit extension and db table logging inside the postgreSQL was validated.

Due to the functional requirement to enable search, quick validations and audit traceability, the in-DB audit implementation got preferred.

### Implementation Details

What: for each audit relevant table, an audit_tablename_version table is created and storing any original table INSERT, DELETE or UPDATE records. Important, we always store:

- Who changed
- What
- When

To support auditing in the project we implemented a custom solution which overrides the `SaveChanges` and `SaveChangesAsync` methods within the `IssuerDbContext`. The specific auditing implementation can be found within the `AuditHandlerV1`.

For all entities that implement the `IAuditableV1` and are inserted or modified the property marked with the `AuditLastEditorV1` Attribute will automatically be set to the current user, as well as the `DateLastChanged` property will be automatically set to the current dateTime.

Additionally the AuditEntity defined in the `AuditEntityV1` Attribute will automatically be created and mapped with the values of the entity. After that the newly created audit entity will be saved in the specific Audit table.

### Why we use versioning for the audit tables?

To ensure that an audit table is never modified, but only entries are added, we have introduced versioning for audit table.

Each audit table has version suffix in the name, this corresponds to the name of the migration in which the audit table was added.

See the example below for further information:

### How to enable an entity to be auditable in the code (Example: Document)

1. Create Audit entity which should contains all properties that are no navigation properties from the auditable entity. The audit entity must implement the `IAuditEntityV1` interface and mark the with the `Key` Attribute.

```c#
public class AuditDocument20240305 : IAuditEntityV1
{
   [Key]
   public Guid AuditV1Id { get; set; }

   ...
}
```

2. The auditable entity needs to implement interface 'IAuditableV1' and be marked with the `AuditEntityV1` Attribute

```c#
[AuditEntityV1(typeof(AuditDocument20240305))]
public class Document : IAuditableV1
```

3. Add DbSet in PortalDbContext for the newly created Entity

```c#
public virtual DbSet<AuditDocument20240305> AuditDocument20240305 { get; set; } = default!;
```

1. Add Migration

Additional relevant information:

- (warning) If not already existing in the original table, a uuid and last_editor_id attribute need to get added to the original entity.
- (warning) whenever the original table attributes are changed (e.g. adding an attribute or deleting and attribute) the already existing audit table will be set to frozen and a new audit table is getting created. All new audit relevant records will be stored in the new audit table

## NOTICE

This work is licensed under the [Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0).

- SPDX-License-Identifier: Apache-2.0
- SPDX-FileCopyrightText: 2024 Contributors to the Eclipse Foundation
- Source URL: https://github.com/eclipse-tractusx/ssi-credential-issuer
