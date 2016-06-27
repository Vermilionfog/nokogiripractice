class CssChangeDetecterController < ApplicationController
  
  # URLにアクセスするためのライブラリの読み込み
  require 'open-uri'
  
  # Nokogiriライブラリの読み込み
  require 'nokogiri'
  
  #並列処理用ライブラリ
  require 'parallel'
  
  #タイマー用ライブラリ
  require 'workers'


  class Change_Detecter
    
    attr_accessor :criteria,:html,:doc,:results
    attr_accessor :status
    MAX_RESULT = 100
    CHARSET = nil
    
    def initialize(criteria)
      @@criteria = criteria
      @@results = Array.new
      @@status = "Initial"
    end
    
    def change_criteria(criteria)
      @@criteria = criteria
    end
    
    ##解析対象となるオブジェクトを取得する
    def analyzing_resource_acquisition
      if(set_HTMLcode)
        set_Nokogiri_doc
        return true
      end
      
      
      return false
    end
    
    
    def text_acquisition_by_css
      if(@@status == "Valid")
        @@doc.xpath(@@criteria.xpath).each do |node|
          puts node
          text = node.css(@@criteria.css).text
          add_result(text)
        end
      end
    end
    
    def add_newcriteria
      if(analyzing_resource_acquisition)
        @@criteria.save
        puts "新しい検索条件を登録しました"
        return true
      else
        return false
      end
      
    end

  
    private
    
    #条件に一致するWebページのソースコードを@@html設定
    def set_HTMLcode
      begin
        @@html = open(@@criteria.url) do |f|
          charset = f.charset # 文字種別を取得
          f.read # htmlを読み込んで変数htmlに渡す
        end
        
        rescue Errno::ENOENT => err
          puts err
          puts @@criteria.url+"は無効なURLです"
          @@status ="Invalid"
          return false
      end

      return true

    end
    
    #Nokogiriで解析可能なファイル形式の変換し@@docに設定
    def set_Nokogiri_doc
      # htmlを用いてオブジェクトを生成
      @@doc = Nokogiri::HTML(@@html,CHARSET)
      @@status = "Valid"
    end
    

    
    #今までに読み取ったことが無いテキストならばResultモデルへ追加する。
    #要素数がMAX_RESULTを超える場合、古いものを削除
    def add_result(text)
      new_result = Result.new(name:@@criteria.name, text:text,search_time:Time.now)
      if(new_result.save)
        puts "Resultモデルに新たな要素を追加しました"
      else
        puts "そのテキストは既に追加されています+"
      end
    end
  end
  
  ##ここ以降CSSChangeDetecterController


  #部分テンプレートformから値を受け取り新たな条件をモデルへ追加
  def criteria_addition
    @new_criteria = SearchCriterium.new(criteria_params)
    @results = Result.all
    
    detecter = Change_Detecter.new(@new_criteria)
    
    #respond_topでhtmlかjsonに出し分け、かつ保存が成功したか否かで処理を変更
    respond_to do |format|
      if (detecter.add_newcriteria)
        format.html { render :action => :display} 
        format.json { render :action => :display } 
      else 
        format.html { render :action => :display } 
        format.json { render :action => :display } 
      end
    end
    
  end
  
  def display

    #新規条件追加用変数
    @new_criteria = SearchCriterium.new
    
    #結果の取得
    @results = Result.all
    
    #検索条件毎にcssタグと一致するテキストを取得し@resultにpush
    @criteria = SearchCriterium.all
    @criteria.each{|crit|
      detecter = Change_Detecter.new(crit);
      detecter.analyzing_resource_acquisition
      detecter.text_acquisition_by_css
    }
    
    
  end

  def edit
    
  end
  
  def _form
   
  end
  
  def _tab_menu
    
  end
  
  def main
    @criteria = SearchCriterium.all
  end
  

  def criteria_params
    if(params.id==edit_book) #動くか要確認、ダメならifを外す
      params.require(:search_criterium).permit(:name,:url,:xpath,:css,:keyword)
    end
    
  end
  
  
  
end

