class PollsController < ApplicationController
  before_filter :login_required, :only => [:new, :create]

  def index
    @polls = Poll.archived.sorted.paginate :page => params[:page], :per_page => 10
    if on_the_first_page?
      poll = Poll.current
      @polls.unshift(poll) if poll
    end
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    @poll = Poll.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @poll && @poll.readable_by?(current_user)
  end

  def new
    @preview_mode = false
    @poll = Poll.new
    raise ActiveRecord::RecordNotFound.new unless @poll && @poll.creatable_by?(current_user)
  end

  def create
    @poll = Poll.new
    raise ActiveRecord::RecordNotFound.new unless @poll && @poll.creatable_by?(current_user)
    @poll.attributes = params[:poll]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @poll.save
      @poll.node = Node.create(:public => false, :user_id => current_user.id)
      flash[:success] = "L'équipe de modération de LinuxFr.org vous remercie pour votre proposition de sondage"
      redirect_to polls_url
    else
      render :new
    end
  end

  def vote
    @poll = Poll.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @poll && @poll.answerable_by?(request.remote_ip)
    @answer = @poll.answers.scoped_by_position(params[:position]).first
    raise ActiveRecord::RecordNotFound unless @answer
    @answer.vote(request.remote_ip)
    flash[:notice] = "Merci d'avoir voté pour ce sondage"
    redirect_to @poll
  end

end
