-- This lists all user IDs who have reviewed a reviewable or any of its parents
	with recursive successors(origin_id, edit_id) as (
			select wae.id, wae.id 
			from word_attribute_edits wae 
			where successor_id is null
		union
			select origin_id, wae.id
			from successors
			join word_attribute_edits wae on wae.successor_id = edit_id
	)
	select distinct successors.origin_id as word_attribute_edit_id, r.reviewer_id 
	from successors
	join reviews r on r.reviewable_type = 'WordAttributeEdit' and r.reviewable_id = edit_id
	where origin_id != edit_id
union
	select wae.id, r.reviewer_id 
	from word_attribute_edits wae
	join reviews r on r.reviewable_type = 'WordAttributeEdit' and r.reviewable_id = wae.id
	where successor_id is null
