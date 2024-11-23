-- This lists all user IDs who have reviewed a reviewable or any of its parents
	with recursive successors(origin_id, edit_id) as (
			select cg.id, cg.id 
			from change_groups cg 
			where successor_id is null
		union
			select origin_id, cg.id
			from successors
			join change_groups cg on cg.successor_id = edit_id
	)
	select distinct successors.origin_id as change_group_id, r.reviewer_id 
	from successors
	join reviews r on r.reviewable_type = 'ChangeGroup' and r.reviewable_id = edit_id
	where origin_id != edit_id
union
	select cg.id, r.reviewer_id 
	from change_groups cg
	join reviews r on r.reviewable_type = 'ChangeGroup' and r.reviewable_id = cg.id
	where successor_id is null
