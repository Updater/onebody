require_relative '../rails_helper'

describe Setup do
  let(:params) { ActionController::Parameters.new({
      person: {
        first_name: 'Torey',
        last_name: 'Heinz',
        email: 'nobody@none.com',
        password: 'secret',
        password_confirmation: 'secret',
        },
      domain_name: 'church.io'
    })}
  let(:setup) { Setup.new(params) }

  shared_examples 'a person initializier' do
      it 'Initializes a new Person with params attributes' do
        expect(setup.person).to be_a(Person)
        expect(setup.person.first_name).to eq params[:person][:first_name]
        expect(setup.person.last_name).to  eq params[:person][:last_name]
        expect(setup.person.email).to      eq params[:person][:email]
      end
  end

  describe '#execute!' do
    context 'Happy Path' do
      before { setup.execute! }

      it_behaves_like 'a person initializier'

      it "saves the new Person" do
        expect(setup.person).to be_persisted
      end

      it 'updates the current site`s hosts' do
        expect(setup.site.host).to eq('church.io')
      end

      # Pending
      # it 'Updates Settings' do
        # Setting.set_global('Contact', 'Bug Notification Email', @person.email)
        # expect(Setting.get('Contact', 'Bug Notification Email')).to eq(params[:person][:email])
        # expect(Setting.get('Contact', 'Tech Support Email')).to     eq(params[:person][:email])
      # end
    end

    context 'with missing domain_name' do
      before {
        params[:domain_name] = nil
        setup.execute!
      }

      it_behaves_like 'a person initializier'

      it "does not save the new Person" do
        expect(setup.person).to_not be_persisted
      end

      it 'adds errors to person' do
        expect(setup.person.errors.full_messages.to_s).to include('Enter the domain for this site')
      end
    end
  end
end
