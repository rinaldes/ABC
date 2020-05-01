class MutationHistoryController < ApplicationController
    def index
        @productmutationhistory = ProductMutationHistory.all
end
