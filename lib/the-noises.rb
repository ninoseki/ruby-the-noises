require 'thor'
require 'fileutils'
require 'open-uri'
require 'ruby-progressbar'
require 'rss'

module TheNoises
  class CLI < Thor
    SUBDIR_NAME = "the-noises"
    BASE_URL = "http://enterjam.net/podcast/noises/"
    RSS_URL = "http://enterjam.net/noises.xml"

    def initialize(args = [], options = {}, config = {})
      super
      self.destination_root = config[:destination_root]
    end

    desc "download [index]", "start download"
    def download(index)
      begin
        i=Integer(index)
      rescue
        raise ArgumentError, "#{index} is not integer"
      end

      url = BASE_URL + "#{index}.mp3"
      show_title(url)
      save(url)
    end

    no_tasks do
      
      def destination_root
        @destination_root
      end

      def destination_root=(root)
        root ||= Dir.home
        @destination_root = File.expand_path(SUBDIR_NAME, root)
      end

      def save(url)
        file_name = File.basename(url)
        file_path = File.expand_path(file_name, destination_root)
        FileUtils.mkdir_p(destination_root)

        begin
          progress_bar = nil
          
          puts "downloading #{url} to #{file_path}"
          open(file_path, 'wb') { |file|
            open(
              url,               
              :content_length_proc => lambda { |content_length|
                if content_length
                  progress_bar = ProgressBar.create(:total => content_length, :format => "%a <%B> %p%% %t")
                end
              },
              :progress_proc => lambda { |transferred_bytes|
                if progress_bar
                  progress_bar.progress = transferred_bytes
                end
              }
            ) { |data| file.write(data.read) } }
        rescue => e
          FileUtils.rm(file_path)
          case e
          when OpenURI::HTTPError
            puts "#{url} is 404"
          else
            puts e
          end
        end

      end

      def show_title(url)
        rss = RSS::Parser.parse(RSS_URL, false)
        item = rss.items.select { |item| item.enclosure.url == url }.first

        title = item ? item.title : "Unkown"
        puts "Title: #{title}"
      end
    end
  end
end
