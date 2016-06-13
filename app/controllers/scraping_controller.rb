# coding: utf-8
class ScrapingController < ApplicationController
  
  # URLにアクセスするためのライブラリの読み込み
  require 'open-uri'
  
  # Nokogiriライブラリの読み込み
  require 'nokogiri'
  
  #並列処理用ライブラリ
  require 'parallel'
  
  #タイマー用ライブラリ
  require 'workers'

  #TEST : このクラスはテスト用のクラスです
  class HTMLAnalyzer

    attr_accessor :html,:doc,:criteria_and_result
    
    def initialize(criteria_and_result)
      @criteria_and_result = criteria_and_result
      html_acquisition()
    end
    
    ##
    def html_acquisition()
      charset = nil

      @html = open(@criteria_and_result.search_criteria.search_target_url) do |f|
        charset = f.charset # 文字種別を取得
        f.read # htmlを読み込んで変数htmlに渡す
      end

      # htmlを用いてオブジェクトを生成
      @doc = Nokogiri::HTML(@html,charset)
    end

    def get_title
      return @doc.title.to_s
    end
    
  end
  
   #TEST : このクラスはテスト用のクラスです
  class HTMLChangedetecter < HTMLAnalyzer

    attr_accessor :reloding_timer_time,:change_detect_timer
    
    def initialize(criteria_and_result)
      super(criteria_and_result)
      puts get_title
    end
    
    def change_detect
      html_acquisition()
      get_text_of_css_tag
    end
    
    #再読み込み間隔の設定
    def set_reloding_timer(msec)
      @reloding_timer_time=msec
    end
    
    def get_text_of_css_tag
      @doc.xpath(criteria_and_result.search_criteria.search_target_xpath).each do |node|
        text = node.css(criteria_and_result.search_criteria.search_target_css).text
        criteria_and_result.add_result(text)
      end
      
    end
    
    #TODO : 開かれる度にタイマーが作成されていく上に、ページを閉じても処理が終わらない。
    #timerの有効化
    def enable_timer
      
      if(@reloding_timer_time ==nil)
        puts "タイマー間隔が未設定の為、タイマーを起動出来ません。"
        return
      end
      @change_detect_timer = Workers::PeriodicTimer.new(@reloding_timer_time) do
        change_detect
      end
      
    end
    
    #timerの無効化
    def invalid_timer
      @@change_detect_timer.cancel
    end
    
  end
  
  class HTMLSearch_criteria_and_result

    attr_accessor :search_target_tag,:reulst,:search_criteria
    MAX_RESULT = 100
    
    def initialize(tag)
      @search_target_tag=tag
      @result = Array.new
      @search_criteria = HTMLSearch_criteria.new
      super()
    end
    
    #TODO : 検索条件に、検索キーワードと一致していたもののみ。を付け加える。
    #今までに読み取ったことが無いテキストならば配列へ追加する。要素数がMAX_RESULTを超える場合、古いものを削除
    def add_result(text)
      if(!@result.include?(text))
        keyword_detection(text)
        @result.push(text)
        puts text
        if(@result.length >MAX_RESULT)
          @result.shift
        end
      end
    end
    
    #resultに新たなテキストを追加する際、キーワードが含まれていれば処理を行う
    def keyword_detection(text)
      if(text.index(@search_criteria.search_target_keyword))
        puts "検索キーワード" +search_criteria.search_target_keyword+"が含まれています"
        #音をならす処理とか。
      end
    end
  
  end

  class HTMLSearch_criteria
    
    attr_accessor :search_target_url,:search_target_xpath,:search_target_css,:search_target_keyword
    def initialize()
      @search_target_url = search_target_url
    end
 
  end
  
  def testing_page
=begin
    #テスト用検索条件の設定
    test_criteria_and_result = HTMLSearch_criteria_and_result.new("TEST")
    search_criteria = test_criteria_and_result.search_criteria
    search_criteria.search_target_url = 'http://www.gizmodo.jp/'
    search_criteria.search_target_xpath = '//div[@class="entry entry_l clfx"]'
    search_criteria.search_target_css = 'h2/a'
    search_criteria.search_target_keyword ='イーロン・マスク'
    
    #検索用クラスの実行
    html_change_detecter = HTMLChangedetecter.new(test_criteria_and_result)
    #html_change_detecter.change_detect
    html_change_detecter.set_reloding_timer(10)
    html_change_detecter.enable_timer
    
    html_change_detecter.get_title
=end

  end
  
  def receive_post

    puts params[:url]
    
    #テスト用検索条件の設定
    test_criteria_and_result = HTMLSearch_criteria_and_result.new("TEST")
    search_criteria = test_criteria_and_result.search_criteria
    search_criteria.search_target_url = params[:url]
    search_criteria.search_target_xpath = params[:xpath]
    search_criteria.search_target_css = params[:css]
    search_criteria.search_target_keyword = params[:keyword]
    
    #検索用クラスの実行
    html_change_detecter = HTMLChangedetecter.new(test_criteria_and_result)
    html_change_detecter.change_detect
    html_change_detecter.set_reloding_timer(10)
    html_change_detecter.enable_timer
    
    puts "Push and Pull Test"
    render 'scraping/testing_page'
  end
  
end
