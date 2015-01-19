require 'yaml'
require 'clier'
require 'pp'

routes = YAML.load_file('routes.yml')["routes"]

pair = Clier.parse ARGV
from = pair[:f]
to   = pair[:t]

def can_import type, refine_routes # importできるtoolの配列を返す
  tools = {}
  refine_routes.each do |tool, types|
    tools[tool] = types if types["import"].include? type
  end
  
  tools
end

def can_export type, refine_routes # exportできるtoolの配列を返す
  tools = {}
  refine_routes.each do |tool, types|
    tools[tool] = types if types["export"].include? type
  end
  
  tools
end

def can_convert from_type, to_type, refine_routes # fromからto二変換できるtoolの配列を返す
  # 論理積はArrayでしか使えないのでまずはkeysで名前だけ抽出する
  tool_names = can_import(from_type, refine_routes).keys & can_export(to_type, refine_routes).keys
  
  tools = {}
  tool_names.each do |tool_name|
    tools[tool_name] = refine_routes[tool_name] # 内容(export, import, etc...)を入れる
  end
  
  tools
end

def can_import? tool_name, type # importできるか？
  routes[tool_name]["import"].include? type
end

def can_export? tool_name, type # exportできるか？
  routes[tool_name]["export"].include? type
end

branch = [] # 変換のための経路
branch.unshift can_export(to, routes) # to形式でexportできるtoolを探索をして候補に入れる

catch :search_branch do

  loop do
    tools_hash = branch[0]
    
    tools_hash.each do |tool_name, types| # 経路チェック
      if types["import"].include? from # すでに目的のtypeにたどり着いたら(経路完成)
        throw :search_branch # 脱出!!
      end
    end
    
    # 経路追加
    can_export_tools = {} # tools_hash中のtoolが対応している形式(types)のいずれかで出力できるtool
    tools_hash.each do |tool_name, types|
      types["import"].each do |type| # tool_nameがimportできるような形式で、出力できるtoolを一つ一つ探索する
        can_export_tools.merge! can_export(type, routes) # 追加
      end
    end
    branch.unshift can_export_tools if can_export_tools != {} # toolがあれば新しい階層にunshift
  end
  
end

puts from
before_export = from
branch.each_with_index do |tools_hash, i| # とりあえず効率化は無しで
  next_tools = branch[i+1]
  tmp_to = ""
  use_tool_name = ""
  
  if next_tools # 次があれば次のtoolのimportと今のtoolのexportを合わせる必要があるが、最後ならいらない
    catch :match_export do
      
      tools_hash.each do |tool_name, types|
        next_tools.each do |n_tool_name, n_types|
          if (types["export"] & n_types["import"]).any? # 次のtoolでimportできて今のtoolでexportできるものがあれば
            tmp_to = (types["export"] & n_types["import"])[0]
            before_export = tmp_to # 次のtoolに備えて今のtoolがexportする形式を記録しておく
            use_tool_name = tool_name
            throw :match_export
          end
        end
      end
      
    end
  else # 最後
    tools_hash.each do |tool_name, types|
      tmp_to = to
      use_tool_name = tool_name
      break if types["import"].include? before_export # 前toolがexportした形式をimportできたら
    end
  end
  
  puts "-> #{tmp_to} with #{use_tool_name}"
end