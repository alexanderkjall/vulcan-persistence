SELECT tmp.asset AS assettype, array_agg(tmp.name) as name FROM (
SELECT unnest (
        t.assets
        ||
        (array[null]::text[])[1:(array_upper(t.assets, 1) is null)::integer]
    )
    AS asset,
    t.name AS name FROM
checktypes t WHERE
NOT EXISTS(
    SELECT * FROM checktypes c WHERE c.created_at > t.created_at AND t.name = c.name
    )
) AS tmp GROUP BY tmp.asset;
