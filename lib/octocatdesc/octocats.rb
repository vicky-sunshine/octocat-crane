require 'oga'
require 'open-uri'
require 'fuzzy_match'

# octocat
# id
# list = document.xpath("//div[@class='item list']")
# name
# list[0].children[1].attributes[0].value
# image url
# list[0].children[3].children[1].attributes[2].value

module OctocatCrane
  class Octocat
    URL = 'https://octodex.github.com/'

    def initialize
      parse_html
    end

    def octocat_id
      @octocat_id ||= parse_octocat_id
    end

    def octocat_name
      @octocat_name ||= parse_octocat_name
    end

    def octocat_url
      @octocat_url ||= parse_octocat_url
    end

    def octocat_name_to_all
      @name_map ||= map_name_to_all
    end

    def search_octocat(keyword)
      @found_octocat = do_search_octocat(keyword)
    end

    private

    def do_search_octocat(keyword)
      result = FuzzyMatch.new(octocat_name).find(keyword)
      map_name_to_all[result]
    end

    def parse_html
      @document = Oga.parse_html(open(URL))
    end

    def parse_octocat_id
      octocat_id = []
      @document.xpath("//div[@class='footer']").each do |element|
        octocat_id << element.children[1].children[0].text.delete('#')
      end
      octocat_id
    end

    def parse_octocat_name
      octocat_name = []
      @document.xpath("//div[@class='item list']").each do |element|
        octocat_name << element.children[1].attributes[0].value
      end
      octocat_name
    end

    def parse_octocat_url
      octocat_url = []
      @document.xpath("//div[@class='item list']").each do |element|
        octocat_url << URL + element.children[1].attributes[0].value
      end
      octocat_url
    end

    def map_name_to_all
      name = parse_octocat_name
      id = parse_octocat_id
      url = parse_octocat_url

      value = name.zip(id.zip(url))
      Hash[name.zip(value)]
    end
  end
end
