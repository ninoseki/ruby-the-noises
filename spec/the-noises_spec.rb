require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'capture-output'

describe "the-noises" do
  let(:cli) { TheNoises::CLI.new } 
  let(:exists_url) { "http://enterjam.net/podcast/noises/226.mp3" }
  let(:not_exists_url) { "http://enterjam.net/podcast/noises/1.mp3" }
  let(:exists_index) { 226 }
  let(:not_exists_index) { 1 } 
  
  describe "save" do
    context "exists url" do
      it "should save .mp3 file" do
        text = Capture.stdout {
          cli.destination_root = Dir.home
          cli.save(exists_url)
        }

        expect(text).to match(/226\.mp3/)
        expect(text).to match(/Progress/)
        expect(text.include?(Dir.home())).to eq(true)

        expect(File.exists?(File.expand_path("226.mp3", cli.destination_root))).to eq(true)
      end
    end

    context "not exists url" do
      it "should not save .mp3 file" do
        text = Capture.stdout {
          cli.destination_root = Dir.home
          cli.save(not_exists_url)
        }

        expect(text).to match(/404/)
        
        expect(File.exists?(File.expand_path("1.mp3", cli.destination_root))).to eq(false)
      end
    end
  end

  describe "show_title" do
    context "rss feed contains url" do
      it "should output title" do
        text = Capture.stdout {
          cli.show_title(exists_url)
        }
        expect(text).to match(/第226回/)    
      end
    end

    context "rss feed doesn't contain url" do
      it "shouldn't output title" do
        text = Capture.stdout {
          # this url is 404
          cli.show_title(not_exists_url)
        }
        expect(text).to match(/Unkown/)    
      end
    end
  end

  describe "download" do
    context "exists index" do
      it "should download .mp3 file" do
        text = Capture.stdout {
          cli.download(exists_index)
        }

        expect(text).to match(/第226回/)    
        expect(text).to match(/226\.mp3/)
        expect(text).to match(/Progress/)
        expect(text.include?(Dir.home())).to eq(true)

        expect(File.exists?(File.expand_path("226.mp3", cli.destination_root))).to eq(true)
      end
    end

    context "exists index with dst option" do
      it "should download .mp3 file" do
        text = Capture.stdout {
          TheNoises::CLI.new.invoke(:download, [exists_index], {:dst => "/tmp"})
        }

        expect(text).to match(/第226回/)    
        expect(text).to match(/226\.mp3/)
        expect(text).to match(/Progress/)
        expect(text.include?("/tmp")).to eq(true)

        expect(File.exists?(File.expand_path("226.mp3", "/tmp/the-noises/"))).to eq(true)
      end
    end

    context "not exists index" do
      it "should not download .mp3 file" do
        text = Capture.stdout {
          cli.download(not_exists_index)
        }

        expect(text).to match(/404/)
        
        expect(File.exists?(File.expand_path("1.mp3", cli.destination_root))).to eq(false)
      end
    end

    context "not exists index with dst option" do
      it "should not download .mp3 file" do
        text = Capture.stdout {
          TheNoises::CLI.new.invoke(:download, [not_exists_index], {:dst => "/tmp"})
        }

        expect(text).to match(/404/)
        expect(text).to match(/Unkown/)   

        expect(File.exists?(File.expand_path("1.mp3", "/tmp/the-noises"))).to eq(false)
      end
    end

    context "invalid param" do
      it "should raise ArgumentError" do
        expect { cli.download("hoge") }.to raise_error(ArgumentError)
      end
    end
  end
end
  
