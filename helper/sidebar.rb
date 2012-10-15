module Ramaze
  module Helper
    module SideBar
      def generate(current=nil)
        # Extra protection
        return nil unless logged_in?

        # Get the domain name currently being returned but the Domain controller
        # If we're not called from a Domain action, set it to an empty String so
        # Ruby doesn't complain
        currentname = ( current.nil? ? "" : current.name)
        
        # Get a list of forward/reverse domains
        # TODO: make it clever, grab zones with recent serials first
        # TODO: cache it, this stuff is a performance hog
        @forward_domains = Domain.filter(~(:name.like('%in-addr.arpa'))).limit(10)
        @reverse_domains = Domain.filter(:name.like('%in-addr.arpa')).limit(10)

        html = generate_header("Forward Zones", @forward_domains, currentname)
        html += generate_header("Reverse Zones", @reverse_domains, currentname)
        sidebar = Ramaze::Gestalt.new
        sidebar.ul(:class => "nav nav-list") do
          html
        end
        sidebar.to_s
      end

      private

      def generate_header(name, entries, current)
        sidebar = Ramaze::Gestalt.new
        sidebar.li(:class => "nav-header") do
          name
        end
        entries.each do |d|
          # Check if current user can see this domain
          next unless user.can?(:read, d.name)

          if current.eql?(d.name)
            sidebar.li(:class => "active") { Domains.a(d.name, :records, d.id) }
          else
            sidebar.li { Domains.a(d.name, :records, d.id) }
          end
        end
        sidebar.li do
          sidebar.em do
            sidebar.a(:href => "#{Domains.r}") do
              sidebar.i(:class => "icon-plus") {}
              "More..."
            end
          end
        end
        sidebar.to_s
      end

    end
  end
end
