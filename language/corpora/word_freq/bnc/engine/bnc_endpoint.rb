# -*- coding: utf-8 -*-
module Language
  module Corpora
    module WordFreq
      class BncEndpoint < Endpoint

        extend Connection::MysqlConnection

        # Ewwwwwwwwwwwwwwwwww....
        WORDFREQBNC_DB    = 'language_corpora_word_freq'
        WORDFREQBNC_TABLE = 'bnc'

        handles('word_stats') do |params, app, responder|
          conditions   = {
            'head_word' => params[:head_word]
          }
          raw_results = mysql_db.get_row_as_hash(WORDFREQBNC_DB, WORDFREQBNC_TABLE, conditions) || {}
          responder.new(raw_results)
        end

      end
    end
  end
end
