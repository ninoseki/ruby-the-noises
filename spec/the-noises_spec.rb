require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'capture-output'

describe "the-noises" do
  let(:cli) { TheNoises::CLI.new } 
  let(:exists_url) { "http://enterjam.net/podcast/noises/226.mp3" }
  let(:not_exists_url) { "http://enterjam.net/podcast/noises/1.mp3" }

  describe "save" do
    context "exists url" do
      it "should save .mp3 file" do
        text = Capture.stdout {
          cli.save(exists_url)
        }

        text.should =~ /226\.mp3/    
        text.should =~ /Progress/

        File.exists?(File.expand_path("226.mp3", cli.destination_root)).should eq(true)
      end
    end

    context "not exists url" do
      it "should not save .mp3 file" do
        text = Capture.stdout {
          cli.save(not_exists_url)
        }

        text.should =~ /404/
        
        File.exists?(File.expand_path("1.mp3", cli.destination_root)).should eq(false)
      end
    end

  end

  describe "show_title" do
    context "rss feed contains url" do
      it "should output title" do
        text = Capture.stdout {
          cli.show_title(exists_url)
        }
        text.should =~ /第226回/    
      end
    end

    context "rss feed doesn't contain url" do
      it "shouldn't output title" do
        text = Capture.stdout {
          # this url is 404
          cli.show_title(not_exists_url)
        }
        text.should =~ /Unkown/    
      end
    end
  end
end
  
