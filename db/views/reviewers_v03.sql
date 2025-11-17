-- This lists all user IDs who have directly reviewed a change group
-- Excludes reviews of predecessors to allow reviewers to review edited versions
select cg.id as change_group_id, r.reviewer_id
from change_groups cg
join reviews r on r.reviewable_type = 'ChangeGroup' and r.reviewable_id = cg.id
