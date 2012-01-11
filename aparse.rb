#!/usr/bin/ruby

require 'json'
require 'net/http'

class Applicant
  
  # initialize an empty applicant as a Hash
  def init_empty_applicant

    @applicant_values = Hash.new
    @applicant_fields = %w{name email about urls}    
    @applicant_fields.each { |field| @applicant_values[field] = nil }
  
  end

  # create applicant from config_file data which 
  # contains one line for each of the required fields
  # name, email, about, urls
  def initialize config_file          
    init_empty_applicant
              
    if File.exist?(config_file)
      lines = IO.readlines(config_file)
      lines.each { |line| parse_line(line) }      
    else
      puts "Config file " + config_file + " not found!"
    end

    # trasform urls string to an array of strings
    unless @applicant_values["urls"].nil?
      @applicant_values["urls"] = @applicant_values["urls"].split("|").map {|url| url.lstrip.rstrip}
    end

    puts @applicant_values.to_json
	end

  # parse a line to fill applicant fields
  def parse_line line    
    @applicant_fields.each do |field|
      @applicant_values[field] = parse_value(line, field + ":") if line.start_with?(field + ":")
    end  
  end

  # parse a line for a specific field (name, email, about, url)
  def parse_value(line, field)  	  
  	return line.gsub(field,"").lstrip.chomp
  end

  # print Applicant data
  def print
    puts @applicant_values
  end

  def valid_application?
    #check that no information is missing
    valid = true

    @applicant_fields.each do |field|
      valid_application = valid_application && (not @applicant_values[field].nil?)
    end
    
    return valid
  end 
  
  def apply url    
    
    if valid_application?   
      #create request      
      uri = URI(url) 
      request = Net::HTTP::Post.new(uri.path)
      request["content-type"] = "application/json"
      request.body = @applicant_values.to_json
    
      # post request
      post_request(uri,request)
    else
      puts "Invalid applicant data"
    end

  end

  def post_request(uri, request)
    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        puts "You've applied to Parse!"
      else
        puts response.value
    end
  end

end

applicant = Applicant.new "aparse.cfg"
applicant.apply "https://www.parse.com/jobs/apply"

