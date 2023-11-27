--drop function queryTPE;
create or replace function queryTPE(
	tenantId uuid,	
	productName text,
	environment text)
returns table (
	tenant_id uuid,
	tenant_name text,
	tenant_description text,
	tenant_short_code text,
	product_id uuid,
	product_name text,
	product_tenant_code text,
	product_environment_id uuid,
	product_environment_name text
)
language plpgsql
as $$
begin 
	return query
	select
		st.id,
		st.tenant_name,
		st.description,
		st.tenant_short_code,
		p.id,
		p.product_name,
		tpe.product_tenant_code,
		spe.id,
		spe."name"
	from 
		public.symplr_tenants st 
	inner join
		public.symplr_tenant_products spt
		on spt.tenant_id=st.id
	inner join 
		public.symplr_products p
		on p.id = spt.product_id
	inner join 
		public.symplr_tenant_product_environments tpe
		on tpe.tenant_id = st.id
	inner join 
		public.symplr_product_environments spe
		on tpe.product_environment_id = spe.id
	where 
		st.id = tenantId; 
	-- can now add and isnull(productName) OR spe.name like(%productName%), etc
end;$$
-------------


drop function queryAttributeValues;
create or replace function queryAttributeValues(
	tenantId uuid
) returns table(
	tenant_id uuid,
	tenant_product_id uuid,
	tenant_product_environment_id uuid,
	attribute_id uuid,
	attribute_name text,
	attribute_value text
)
language plpgsql
as $$
begin 
	return query
	select
		t.id,
		uuid_nil(),
		uuid_nil(),
		a.id,
		a."name",
		tav.value
	from 
		public.symplr_tenants t
	inner join
		public.symplr_tenants_attributes_values tav
		on tav.tenant_id = t.id
	inner join 
		public.symplr_attributes a
		on a.id=tav.attribute_id
	where 
		t.id = tenantId
	--and a."type" <> "secret" etc;
	union all 
		select t.id,
		tp.id,
		uuid_nil(),
		a.id,
		a."name",
		tpav.value
	from
		public.symplr_tenants t
	inner join
		public.symplr_tenant_products tp
		on tp.tenant_id = t.id
	inner join 
		public.symplr_tenants_products_attributes_values tpav
		on tpav.tenant_product_id = tp.id
	inner join 
		public.symplr_attributes a
		on a.id=tpav.attribute_id	
	where 
		t.id = tenantId;
	-- now union all with tenant product environment AVs
	
end;$$



	