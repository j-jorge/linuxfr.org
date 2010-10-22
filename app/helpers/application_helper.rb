module ApplicationHelper

  def title(title, tag=nil)
    title = h(title)
    @title << title
    content_tag(tag, title) if tag
  end

  def h1(str)
    title(str, :h1)
  end

  def feed(title, link=nil)
    link ||= { :format => :atom }
    @feeds[link] = title
  end

  def meta_for(content)
    @author      = content.user.name if content.respond_to?(:user) && content.user
    @keywords   += content.node.popular_tags.map &:name
    @description = content.title
  end

end
