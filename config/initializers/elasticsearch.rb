module Elasticsearch
  es_config = (YAML.load_file("#{Rails.root}/config/elasticsearch.yml") || {})[Rails.env]
  INDEX_NAME = es_config && es_config['index_name'].present? ? es_config['index_name'].freeze : "#{Rails.env}:jobs:head".freeze
  WRITE_INDEX_NAME = ENV['BONSAI_WRITE'].presence || INDEX_NAME
end
