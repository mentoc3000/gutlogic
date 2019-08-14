const chai = require('chai');
const assertArrays = require('chai-arrays');
chai.use(assertArrays);

var expect = chai.expect;

// Require exports file with endpoint and auth info
const client = require('./aws-exports').client;

// Import gql helper and craft a GraphQL query
const gql = require('graphql-tag');



const clearFoodDb = async () => {

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
        });
    });

}

describe('Food database', () => {
    before('clear food database', clearFoodDb);

    describe('listFoods', () => {

        it('should get all foods', async () => {
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
            });
            const data = result.data.listFoods;
            expect(data.__typename).to.equal('PaginatedFoods');
            expect(data.items).to.be.array();
        });
    });

    describe('createFood', () => {
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
            });
            const data = result.data.createFood;
            expect(data.__typename).to.equal('Food');
            expect(data.name).to.equal('Bacon');
            expect(data.nameId).to.equal('food');
        });
    });

    describe('getFood', () => {
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
            });
            const getData = getResult.data.getFood;
            expect(getData.__typename).to.equal('Food');
            expect(getData.name).to.equal(name);
        });
    });

    describe('deleteFood', () => {
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
            });
            const data = result.data.deleteFood;
            expect(data.__typename).to.equal('Food');
            expect(data.nameId).to.equal(nameId);
            expect(data.entryId).to.equal(entryId);
        });
    });

    describe('updateFood', () => {
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
                    name
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
            });
            const data = result.data.updateFood;
            expect(data.name).to.equal(newName);
        });
    });

    after('clear food database', clearFoodDb);
});