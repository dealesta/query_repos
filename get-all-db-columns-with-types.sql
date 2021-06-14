declare @sql nvarchar(max);

select @sql = 
    (select ' UNION ALL
        SELECT @@SERVERNAME server_name, @@SERVICENAME service_name,' +  + quotename(name,'''') + ' as database_name,
               s.name COLLATE DATABASE_DEFAULT
                    AS schema_name,
               t.name COLLATE DATABASE_DEFAULT as table_name, 
			   c.name COLLATE DATABASE_DEFAULT as column_name, 
			   ty.name COLLATE DATABASE_DEFAULT as column_type
               FROM '+ quotename(name) + '.sys.tables t 
               JOIN '+ quotename(name) + '.sys.schemas s 
                    ON s.schema_id = t.schema_id 
			   JOIN '+ quotename(name) + '.sys.columns c 
					ON t.object_id = c.object_id
			   JOIN '+ quotename(name) + '.sys.types ty ON c.user_type_id = ty.user_type_id'
    from sys.databases 
    where state=0
    order by [name] for xml path(''), type).value('.', 'nvarchar(max)');

set @sql = stuff(@sql, 1, 12, '') + ' order by database_name, 
                                               schema_name,
                                               table_name,
											   column_name,
											   column_type';

execute (@sql);

-- Ref:
-- https://stackoverflow.com/questions/18070177/how-to-get-current-instance-name-from-t-sql
-- https://dataedo.com/kb/query/sql-server/list-all-tables-in-all-databases
