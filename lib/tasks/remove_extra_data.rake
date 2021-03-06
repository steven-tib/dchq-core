namespace :remove_extra_data do
  task except_company: :environment do
    ENV['from_rake_task'] = 'true'

    PaperTrail.enabled = false

    companies = Company.where("id != ?", ENV['company_id'])

    5.times do
      companies.find_each do |company|
        puts "*******Starting remove data from company #{ company.name }"

        puts '*******Removing Users:'
        company.stores.each do |store|
          store.certification_levels.destroy_all
          store.certification_level_costs.destroy_all
          store.payment_methods.with_deleted.map(&:destroy!)
          store.tax_rates.with_deleted.map(&:destroy!)
          store.commission_rates.with_deleted.map(&:destroy!)
          store.event_trips.delete_all

          store.events.with_deleted.find_each do |event|
            event.event_user_participants.destroy_all
            event.event_customer_participants.destroy_all
            event.destroy!
          end

          store.boats.destroy_all
          store.working_times.destroy_all
          store.event_tariffs.destroy_all
          store.finance_reports.destroy_all
          store.email_setting.try(:destroy)
          store.kit_hires.destroy_all
          store.transports.destroy_all
          store.insurances.destroy_all
          store.additionals.destroy_all

          store.type_of_services.destroy_all
          store.service_kits.destroy_all
          store.services.map(&:destroy)
          store.categories.find_each do |category|
            category.products.with_deleted.map(&:destroy!)
            category.destroy
          end

          store.brands.find_each do |brand|
            brand.products.with_deleted.map(&:destroy!)
            brand.delete
          end

          store.products.with_deleted.find_each do |product|
            product.service_items.map(&:destroy)
            product.delete
          end

          store.miscellaneous_products.map(&:destroy)
          store.sales.with_deleted.find_each do |sale|
            sale.event_customer_participants.with_deleted.map(&:destroy!)
            sale.sale_products.map(&:refunded_sale_products).map(&:delete)
            sale.sale_products.map(&:delete)
            sale.sale_customers.map(&:delete)
            sale.payments.map(&:delete)
            sale.credit_notes.map(&:destroy)
            sale.products.with_deleted.map(&:logo).map(&:delete)
            sale.products.with_deleted.map(&:destroy!)
            sale.destroy!
          end

          store.tills.destroy_all

          store.renteds.map(&:destroy)
          store.rental_products.destroy_all
          store.rentals.map{ |d| d.destroy }

          store.xero.try(:destroy)
          store.scuba_tribe.try(:destroy)

          store.destroy

        end

        company.customers.with_deleted.find_each do |customer|
          customer.certification_level_memberships.destroy_all
          customer.incidents.destroy_all
          customer.sale_customers.find_each do |s|
            s.destroy
          end
          customer.event_customer_participants.map(&:destroy!)
          customer.credit_notes.destroy_all
          customer.custom_fields.destroy_all
          customer.rentals.map(&:discount).map(&:destroy)
          customer.rentals.destroy_all
          customer.destroy!
        end

        company.gift_card_types.destroy_all
        company.suppliers.find_each do |s|
          s.address.try(:destroy!)
          s.products.map(&:destroy!)
          s.destroy!
        end

        company.users.with_deleted.find_each do |user|
          user.address.try(:destroy!)
          user.notes.destroy_all
          user.user_holidays.destroy_all
          user.tills.delete_all
          user.rentals.destroy_all
          user.sales.map(&:destroy!)
          user.destroy!
        end
        company.destroy
      end

      Address.with_deleted.where(addressable_type: 'DiveCentre').map(&:destroy!)

      Address.with_deleted.includes(:addressable).find_each do |a|
        a.destroy! if a.addressable.blank?
      end

      Image.find_each do |i|
        i.destroy if i.imageable.blank?
      end

      AllPayment.includes(:cashier).find_each do |p|
        p.destroy if p.cashier.blank?
      end

      Attachment.find_each do |a|
        a.destroy if a.attachable.blank?
      end

      BusinessContact.with_deleted.find_each do |b|
        b.destroy! if b.supplier.blank?
      end

      CertificationLevelCost.where("store_id != 0").find_each do |c|
        c.destroy if c.store.blank?
      end

      CertificationLevelMembership.find_each do |c|
        c.destroy if c.memberable.blank?
      end

      CertificationLevel.where("store_id IS NOT NULL").find_each do |c|
        c.destroy if c.store.blank?
      end

      CommissionRate.includes(:store).find_each do |c|
        c.destroy if c.store.blank?
      end

      Stores::CustomField.includes(:customer).find_each do |c|
        c.destroy if c.customer.blank?
      end

      Customer.includes(:company).with_deleted.find_each do |c|
        c.destroy! if c.company.blank?
      end

      Discount.find_each do |d|
        d.destroy if d.discountable.blank?
      end

      EventCustomerParticipantOptions::EventCustomerParticipantOption.includes(:event_customer_participant).find_each do |e|
        e.destroy if e.event_customer_participant.blank?
      end

      EventCustomerParticipant.with_deleted.includes(:customer).find_each do |e|
        e.destroy! if e.customer.blank?
      end

      EventTrip.includes(:store).find_each do |e|
        e.destroy if e.store.blank?
      end

      EventUserParticipant.includes(:user).find_each do |e|
        e.destroy if e.user.blank?
      end

      Event.with_deleted.includes(:store).find_each do |e|
        e.destroy! if e.store.blank?
      end

      ExtraEvents::ExtraEvent.includes(:store).find_each do |e|
        e.destroy if e.store.blank?
      end

      Image.find_each do |i|
        i.delete if i.imageable.blank?
      end

      Services::Kit.find_each do |k|
        k.destroy if k.service.blank?
      end

      MaterialPrice.includes(:certification_level_cost).find_each do |m|
        m.destroy if m.certification_level_cost.blank?
      end

      Note.find_each do |n|
        n.destroy if n.notable.blank?
      end

      PaymentMethod.with_deleted.includes(:store).find_each do |p|
        p.destroy! if p.store.blank?
      end

      SaleCustomer.includes(:sale).find_each do |s|
        s.destroy if s.sale.blank?
      end

      SaleProduct.includes(:sale).find_each do |s|
        s.destroy if s.sale.blank?
      end

      Sale.with_deleted.includes(:store).find_each do |s|
        s.destroy! if s.store.blank?
      end

      StoreProduct.with_deleted.includes(:store).find_each do |s|
        s.destroy! if s.store.blank?
      end

      Supplier.with_deleted.includes(:company).find_each do |s|
        s.destroy! if s.company.blank?
      end

      TaxRate.with_deleted.includes(:store).find_each do |s|
        s.destroy! if s.store.blank?
      end

      Services::TimeInterval.includes(:service).find_each do |s|
        s.destroy if s.service.blank?
      end

      ActsAsTaggableOn::Tagging.includes(:tag).find_each do |t|
        if t.taggable_type == 'Profile' || t.taggable_type == 'Membership' || t.taggable.blank?
          t.tag.destroy
          t.destroy
        end
      end

      ActsAsTaggableOn::Tag.find_each do |t|
        t.destroy if ActsAsTaggableOn::Tagging.find_by_tag_id(t.id).blank?
      end

      User.with_deleted.includes(:company).find_each do |u|
        u.destroy! if u.company.blank?
      end

      Currency.find_each do |c|
        c.destroy if c.stores.blank?
      end

      Stores::ScubaTribe.find_each do |s|
        s.destroy if s.store.blank?
      end

      PricingPlan.find_each do |p|
        p.destroy if p.companies.blank?
      end
    end

    ActiveRecord::Base.connection.execute("TRUNCATE versions RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE sessions RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE active_admin_comments RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE documentation_pages RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE admin_users RESTART IDENTITY")

    AdminUser.create!([{ email: "admin@example.com", password: "changeme" }])
  end
end
