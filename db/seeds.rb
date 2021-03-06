require 'faraday'
require 'json'

response = Faraday.get('http://drug.org.pl/presentations')
presentations = JSON.parse(response.body)

events = []

presentations.each do |data|
  venue = Venue.find_or_initialize_by_name(data['event']['venue']['name'])
  if venue.new_record?
    venue.address   = data['event']['venue']['address']
    venue.latitude  = data['event']['venue']['location'].first
    venue.longitude = data['event']['venue']['location'].last
    venue.save!
  end

  event = Event.find_or_initialize_by_title(data['event']['title'].upcase)
  if event.new_record?
    event.starting_at = Time.zone.parse(data['event']['starting_at'])
    event.description = data['event']['description']
    event.venue = venue
    event.save!
    events << event
  end

  speakers = data['speakers'].map { |p| Person.find_or_initialize_by_full_name(p) }
  presentation = Presentation.find_or_initialize_by_title(data['title'])
  if presentation.new_record?
    presentation.speakers = speakers
    presentation.event    = event
    presentation.save!
    presentation.postpone! if data['postponed']
  end
end


events.each do |event|
  slug = event.title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '') 
  response = Faraday.get('http://drug.org.pl/events/'+slug+'/attendants.json')
  attendants = JSON.parse(response.body)
  
  attendants.each do |data|
    attendant = Person.find_or_initialize_by_facebook_uid(data['uid'])
    if attendant.new_record?
      attendant.full_name = data['name']
      attendant.save!
    end
    attendant.attend!(event)
  end
  
end


puts "Presentations: #{Presentation.count}, Events: #{Event.count}, Venues: #{Venue.count}"
