-- FUNCTION: public.updatecacheitemformat(text, text, text, timestamp with time zone)

-- DROP FUNCTION public.updatecacheitemformat(text, text, text, timestamp with time zone);

CREATE OR REPLACE FUNCTION public.updatecacheitemformat(
	"SchemaName" text,
	"TableName" text,
	"DistCacheId" text,
	"UtcNow" timestamp with time zone)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE NOT LEAKPROOF 
AS $function$

DECLARE v_Query Text;
BEGIN

v_query := format('UPDATE %I.%I ' ||
				  'SET "ExpiresAtTime" = '
                  	'CASE ' ||
                  		'WHEN (SELECT %I.DateDiff(''seconds''::varchar, $1, "AbsoluteExpiration")) <= "SlidingExpirationInSeconds" ' ||
                  		'THEN "AbsoluteExpiration" ' ||
         		  		'ELSE $1 + "SlidingExpirationInSeconds" *  interval ''1 second'' ' ||
    			  	'END ' ||
				  'WHERE "Id" = $2 ' ||
  				  'AND $1 <= "ExpiresAtTime" ' ||
  				  'AND "SlidingExpirationInSeconds" IS NOT NULL ' ||
  				  'AND ("AbsoluteExpiration" IS NULL OR "AbsoluteExpiration" <> "ExpiresAtTime")', "SchemaName", "TableName", "SchemaName");
EXECUTE v_Query using "UtcNow", "DistCacheId";                

END

$function$;

ALTER FUNCTION public.updatecacheitemformat(text, text, text, timestamp with time zone)
    OWNER TO postgres;
