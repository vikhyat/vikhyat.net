# coding: utf-8
require 'mysql'
require 'thread'
require_relative '../../../babushka-deps/config.rb'

def mysql_connect
  $my = Mysql.init
  $my.options(Mysql::SET_CHARSET_NAME, 'utf8')
  $my.real_connect('127.0.0.1', 'anime_graph', config(:mysql_anime_graph_password), 'anime')
  $relatedq   = $my.prepare("SELECT other, weight FROM related WHERE anime=? ORDER BY weight DESC LIMIT 20")
  $relatedqpm = $my.prepare("SELECT * FROM related AS t1 INNER JOIN metadata AS t2 ON t1.other = t2.anime WHERE t1.anime=? ORDER BY t1.weight DESC LIMIT 20")
  $metaq      = $my.prepare("SELECT * FROM metadata WHERE anime=? LIMIT 1")
end
mysql_connect

$sema = Mutex.new

def get_related(id)
  begin
    $sema.synchronize do
      related = []
      $relatedq.execute(id.to_i).each do |other, weight|
        related.push( {"id" => other, "sim" => weight} )
      end
      related
    end
  rescue Mysql::ClientError::ServerGoneError => e
    mysql_connect
    get_related(id)
  end
end

def get_related_metadata(id)
  begin
    $sema.synchronize do
      related = []
      $relatedqpm.execute(id.to_i).each do |_, other, weight, _, title, alt_title, score, members, synopsis, genres, relateds, rating|
        related.push( {"id"=>other, "sim"=>weight, "title"=>title, "synopsis"=>synopsis, "genres"=>genres, "related" => relateds, "rating"=>rating, "score" => score, "members" => members} )
      end
      related
    end
  rescue Mysql::ClientError::ServerGoneError => e
    mysql_connect
    get_related_metadata(id)
  end
end

def get_metadata(id)
  begin
    $sema.synchronize do
      meta = nil
      $metaq.execute(id.to_i).each do |id, title, alt_title, score, members, synopsis, genres, relateds, rating|
        meta = {"id"=>id, "title"=>title, "synopsis"=>synopsis, "genres"=>genres, "related" => relateds, "rating"=>rating, "score" => score, "members" => members}
      end
      meta
    end
  rescue Mysql::ClientError::ServerGoneError => e
    mysql_connect
    get_metadata(id)
  end
end

get '/anime_graph/related/:anime' do
  get_related(params[:anime].to_i).to_json
end

get '/anime_graph/related/metadata/:anime' do
  get_related_metadata(params[:anime].to_i).to_json
end

get '/anime_graph/metadata/:anime' do
  get_metadata(params[:anime].to_i).to_json
end
