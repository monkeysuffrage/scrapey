require 'scrapey'
# if you created a scrapey project you can fill out the database connection
# information in config/config.yml

tables 'Movie', 'Actor' # create ActiveRecord  models

page = get 'http://www.imdb.com/movies-in-theaters/'

page.search('div.list_item').each do |div|
  movie = Movie.find_or_create_by_title div.at('h4 a').text
  div.search('span[@itemprop="actors"] a').each do |a|
    actor = Actor.find_or_create_by_name a.text
  end
end