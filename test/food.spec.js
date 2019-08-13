const chai = require('chai');
const assertArrays = require('chai-arrays');
chai.use(assertArrays);

var expect = chai.expect;

global.WebSocket = require('ws');
global.window = global.window || {
    setTimeout: setTimeout,
    clearTimeout: clearTimeout,
    WebSocket: global.WebSocket,
    ArrayBuffer: global.ArrayBuffer,
    addEventListener: function () { },
    navigator: { onLine: true }
};
global.localStorage = {
    store: {},
    getItem: function (key) {
        return this.store[key]
    },
    setItem: function (key, value) {
        this.store[key] = value
    },
    removeItem: function (key) {
        delete this.store[key]
    }
};
require('es6-promise').polyfill();
require('isomorphic-fetch');

// Require exports file with endpoint and auth info
const aws_exports = require('./aws-exports').default;

// Require AppSync module
const AUTH_TYPE = require('aws-appsync/lib/link/auth-link').AUTH_TYPE;
const AWSAppSyncClient = require('aws-appsync').default;

const url = aws_exports.ENDPOINT;
const region = aws_exports.REGION;
// const type = AUTH_TYPE.AWS_IAM;
const type = AUTH_TYPE.API_KEY
// const type = AUTH_TYPE.AMAZON_COGNITO_USER_POOLS

// If you want to use API key-based auth
const apiKey = 'da2-dq2yiriyi5aa3du5nlineuwjom';
// If you want to use a jwtToken from Amazon Cognito identity:
const jwtToken = 'xxxxxxxx';

// If you want to use AWS...
const AWS = require('aws-sdk');
const credentials = AWS.config.credentials;


// Set up Apollo client
const client = new AWSAppSyncClient(
    {
        url: url,
        region: region,
        auth: {
            type: type,
            // credentials: credentials,
            apiKey: apiKey,
        },
        disableOffline: true,
    },     //Uncomment for AWS Lambda
    // {
    //     defaultOptions: {
    //         query: {
    //             fetchPolicy: 'network-only',
    //             errorPolicy: 'all',
    //         },
    //         mutate: {
    //             fetchPolicy: 'no-cache',
    //             errorPolicy: 'all',
    //         }
    //     },
    // }
);

// Import gql helper and craft a GraphQL query
const gql = require('graphql-tag');


describe('Food database', function () {
    it('should get all foods', async function () {
        const query = gql(`
        query ListFoods {
        listFoods {
            items {
                nameId
                entryId
                name
            }
            nextToken
        }
        }`);

        await client.hydrated();
        const result = await client.query({
            query: query,
            fetchPolicy: 'network-only',
        });
        const data = result.data.listFoods;
        expect(data.__typename).to.equal('PaginatedFoods');
        expect(data.items).to.be.array();
    });

    it('should create a food', async () => {
        const createFood = gql(`
        mutation CreateFood($input: CreateFoodInput!) {
        createFood(input: $input) {
            nameId
            entryId
            name
        }
        }`);

        await client.hydrated();
        const result = await client.mutate({
            mutation: createFood,
            variables: {
                input: {
                    name: 'Bacon',
                }
            },
            fetchPolicy: 'no-cache',
        });
        const data = result.data.createFood;
        expect(data.__typename).to.equal('Food');
        expect(data.name).to.equal('Bacon');
        expect(data.nameId).to.equal('food');
    });

    it('should get a food', async () => {
        const createFood = gql(`
        mutation CreateFood($input: CreateFoodInput!) {
        createFood(input: $input) {
            nameId
            entryId
            name
        }
        }`);

        const name = 'Bacon';

        await client.hydrated();
        const createResult = await client.mutate({
            mutation: createFood,
            variables: {
                input: {
                    name: name,
                }
            },
            fetchPolicy: 'no-cache',
        });
        const createData = createResult.data.createFood;
        expect(createData.nameId).to.be.string;
        const nameId = createData.nameId;
        const entryId = createData.entryId;

        const getFood = gql(`
        query getFood($nameId: String!, $entryId: String!) {
        getFood(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            name
        }
        }`);

        const getResult = await client.query({
            query: getFood,
            variables: {
                nameId: nameId,
                entryId: entryId,
            },
            fetchPolicy: 'network-only',
        });
        const getData = getResult.data.getFood;
        expect(getData.__typename).to.equal('Food');
        expect(getData.name).to.equal(name);
    });

    it('should delete a food', async () => {
        const createFood = gql(`
        mutation CreateFood($input: CreateFoodInput!) {
        createFood(input: $input) {
            nameId
            entryId
            name
        }
        }`);

        const name = 'Sausage';

        await client.hydrated();
        const createResult = await client.mutate({
            mutation: createFood,
            variables: {
                input: {
                    name: name,
                }
            },
            fetchPolicy: 'no-cache',
        });
        const createData = createResult.data.createFood;
        expect(createData.nameId).to.be.string;
        const nameId = createData.nameId;
        const entryId = createData.entryId;

        const deleteFood = gql(`
        mutation DeleteFood($input: GutAiIdInput!) {
        deleteFood(input: $input) {
            nameId
            entryId
        }
        }`);

        await client.hydrated();
        const result = await client.mutate({
            mutation: deleteFood,
            variables: {
                input: {
                    nameId: nameId,
                    entryId: entryId,
                }
            },
            fetchPolicy: 'no-cache',
        });
        const data = result.data.deleteFood;
        expect(data.__typename).to.equal('Food');
        expect(data.nameId).to.equal(nameId);
        expect(data.entryId).to.equal(entryId);
    });

    it('should update a food', async () => {
        const createFood = gql(`
        mutation CreateFood($input: CreateFoodInput!) {
        createFood(input: $input) {
            nameId
            entryId
            name
        }
        }`);

        const name = 'Orange Juice';

        await client.hydrated();
        const createResult = await client.mutate({
            mutation: createFood,
            variables: {
                input: {
                    name: name,
                }
            },
            fetchPolicy: 'no-cache',
        });
        const createData = createResult.data.createFood;
        expect(createData.nameId).to.be.string;
        const nameId = createData.nameId;
        const entryId = createData.entryId;

        const updateFood = gql(`
        mutation UpdateFood($input: UpdateFoodInput!) {
        updateFood(input: $input) {
            nameId
            entryId
        }
        }`);

        const newName = 'Mimosa'

        const result = await client.mutate({
            mutation: updateFood,
            variables: {
                input: {
                    nameId: nameId,
                    entryId: entryId,
                    name: newName,
                }
            },
            fetchPolicy: 'no-cache',
        });
        const data = result.data.updateFood;
        expect(data.name).to.equal(newName);
    });

    after('Clear food database', async () => {
        const listFoods = gql(`
        query ListFoods {
        listFoods {
            items {
                nameId
                entryId
                name
            }
            nextToken
        }
        }`);

        await client.hydrated();
        const result = await client.query({
            query: listFoods,
            fetchPolicy: 'network-only',
        });
        
        result.data.listFoods.items.forEach(item => {

            const deleteFood = gql(`
            mutation DeleteFood($input: GutAiIdInput!) {
            deleteFood(input: $input) {
                nameId
                entryId
            }
            }`);
    
            const result = client.mutate({
                mutation: deleteFood,
                variables: {
                    input: {
                        nameId: item.nameId,
                        entryId: item.entryId,
                    }
                },
                fetchPolicy: 'no-cache',
            });            
        });

    });
});