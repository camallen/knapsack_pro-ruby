describe 'Request API /v1/build_distributions/subset' do
  let(:valid_endpoint) { 'http://api.knapsackpro.dev:3000' }
  let(:invalid_endpoint) { 'http://api.fake-knapsackpro.dev:3000' }
  let(:valid_test_suite_token) { '3fa64859337f6e56409d49f865d13fd7' }
  let(:invalid_test_suite_token) { 'fake' }

  let(:action) do
    KnapsackPro::Client::API::V1::BuildDistributions.subset(
      commit_hash: 'abcdefg',
      branch: 'master',
      node_total: '2',
      node_index: '1',
      test_files: [
        {
          'path' => 'a_spec.rb'
        },
        {
          'path' => 'b_spec.rb'
        }
      ],
    )
  end
  let(:connection) { KnapsackPro::Client::Connection.new(action) }

  before do
    KnapsackPro::Client::Connection.credentials.set = {
      endpoint: endpoint,
      test_suite_token: test_suite_token
    }
  end

  context 'when success' do
    let(:endpoint) { valid_endpoint }
    let(:test_suite_token) { valid_test_suite_token }

    it do
      VCR.use_cassette("api/v1/build_distributions/subset") do
        response = connection.call
        puts response
      end

      expect(connection.errors?).to be false
      expect(connection.success?).to be true
    end
  end

  context 'when failure' do
    context 'when invalid test suite token' do

    end

    context 'when timeout' do

    end
  end
end
