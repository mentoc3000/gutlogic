const chai = require('chai');
const assertArrays = require('chai-arrays');
chai.use(assertArrays);

var expect = chai.expect;

// Require exports file with endpoint and auth info
const client = require('./aws-exports').client;

// Import gql helper and craft a GraphQL query
const gql = require('graphql-tag');



describe('Medicine database', () => {
    before('clear medicine database', clearMedicineDb);

    describe('listMedicines', () => {

        it('should get all medicines', async () => {
            const query = gql(`
                query ListMedicines {
                listMedicines {
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
            const data = result.data.listMedicines;
            expect(data.__typename).to.equal('PaginatedMedicines');
            expect(data.items).to.be.array();
        });
    });

    describe('createMedicine', () => {
        it('should create a medicine', async () => {
            const createMedicine = gql(`
                mutation CreateMedicine($input: CreateMedicineInput!) {
                createMedicine(input: $input) {
                    nameId
                    entryId
                    name
                }
                }`);

            await client.hydrated();
            const result = await client.mutate({
                mutation: createMedicine,
                variables: {
                    input: {
                        name: 'Bacon',
                    }
                },
            });
            const data = result.data.createMedicine;
            expect(data.__typename).to.equal('Medicine');
            expect(data.name).to.equal('Bacon');
            expect(data.nameId).to.equal('medicine');
        });
    });

    describe('getMedicine', () => {

        let nameId;
        let entryId;
        const name = 'Bacon';

        before('create a medicine', async () => [nameId, entryId] = await createMedicine(name));

        it('should get a medicine', async () => {

            const getMedicine = gql(`
                query getMedicine($nameId: String!, $entryId: String!) {
                getMedicine(nameId: $nameId, entryId: $entryId) {
                    nameId
                    entryId
                    name
                }
                }`);

            const getResult = await client.query({
                query: getMedicine,
                variables: {
                    nameId: nameId,
                    entryId: entryId,
                },
            });
            const getData = getResult.data.getMedicine;
            expect(getData.__typename).to.equal('Medicine');
            expect(getData.name).to.equal(name);
        });
    });

    describe('deleteMedicine', () => {

        let nameId;
        let entryId;
        const name = 'Bacon';

        beforeEach('create a medicine', async () => [nameId, entryId] = await createMedicine(name));

        it('should delete a medicine', async () => {

            const deleteMedicine = gql(`
                mutation DeleteMedicine($input: GutAiIdInput!) {
                deleteMedicine(input: $input) {
                    nameId
                    entryId
                }
                }`);

            await client.hydrated();
            const result = await client.mutate({
                mutation: deleteMedicine,
                variables: {
                    input: {
                        nameId: nameId,
                        entryId: entryId,
                    }
                },
            });
            const data = result.data.deleteMedicine;
            expect(data.__typename).to.equal('Medicine');
            expect(data.nameId).to.equal(nameId);
            expect(data.entryId).to.equal(entryId);
        });
    });

    describe('updateMedicine', () => {

        let nameId;
        let entryId;
        const name = 'Bacon';

        beforeEach('create a medicine', async () => [nameId, entryId] = await createMedicine(name));

        it('should update a medicine', async () => {

            const updateMedicine = gql(`
                mutation UpdateMedicine($input: UpdateMedicineInput!) {
                updateMedicine(input: $input) {
                    nameId
                    entryId
                    name
                }
                }`);

            const newName = 'Mimosa'

            const result = await client.mutate({
                mutation: updateMedicine,
                variables: {
                    input: {
                        nameId: nameId,
                        entryId: entryId,
                        name: newName,
                    }
                },
            });
            const data = result.data.updateMedicine;
            expect(data.name).to.equal(newName);
        });
    });

    after('clear medicine database', clearMedicineDb);
});

async function clearMedicineDb() {

    const listMedicines = gql(`
    query ListMedicines {
    listMedicines {
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
        query: listMedicines,
        fetchPolicy: 'network-only',
    });

    result.data.listMedicines.items.forEach(item => {

        const deleteMedicine = gql(`
        mutation DeleteMedicine($input: GutAiIdInput!) {
        deleteMedicine(input: $input) {
            nameId
            entryId
        }
        }`);

        const result = client.mutate({
            mutation: deleteMedicine,
            variables: {
                input: {
                    nameId: item.nameId,
                    entryId: item.entryId,
                }
            },
        });
    });

}

async function createMedicine(name) {
    const createMedicine = gql(`
        mutation CreateMedicine($input: CreateMedicineInput!) {
        createMedicine(input: $input) {
            nameId
            entryId
            name
        }
        }`);

    await client.hydrated();
    const createResult = await client.mutate({
        mutation: createMedicine,
        variables: {
            input: {
                name: name,
            }
        },
    });
    const createData = createResult.data.createMedicine;
    const nameId = createData.nameId;
    const entryId = createData.entryId;
    return [nameId, entryId];
}