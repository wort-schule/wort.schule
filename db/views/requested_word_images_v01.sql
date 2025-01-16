select name, meaning, requests.request_count
from words
join (
	select word_id, count(word_id) as request_count
	from image_requests ir 
	group by word_id
) requests on words.id = requests.word_id
order by hit_counter desc, name asc
