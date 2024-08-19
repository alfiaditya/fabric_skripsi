'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class MyWorkload extends WorkloadModuleBase {
    constructor() {
        super();
        this.txIndex = -1;
        this.colors = ['red', 'blue', 'green', 'black', 'white', 'pink', 'rainbow'];
        this.owners = ['Alice', 'Bob', 'Claire', 'David'];
    }

    /**
    * Initialize the workload module with the given parameters.
    * @param {number} workerIndex The 0-based index of the worker instantiating the workload module.
    * @param {number} totalWorkers The total number of workers participating in the round.
    * @param {number} roundIndex The 0-based index of the currently executing round.
    * @param {Object} roundArguments The user-provided arguments for the round from the benchmark configuration file.
    * @param {ConnectorBase} sutAdapter The adapter of the underlying SUT.
    * @param {Object} sutContext The custom context object provided by the SUT adapter.
    * @async
    */
    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);
    }
    async submitTransaction() {
        this.txIndex++;

        const earTag = `${this.roundIndex}_${this.workerIndex}_${this.txIndex}_${Date.now()}`;
        const jenisSapi = (((this.txIndex % 10) + 1) * 10).toString();
        const tanggalMasuk = (((this.txIndex % 10) + 1) * 10).toString(); 
        const beratAwal = (((this.txIndex % 10) + 1) * 10).toString();
        const arsipSapi = (((this.txIndex % 10) + 1) * 10).toString();
        const umurMasuk = (((this.txIndex % 10) + 1) * 10).toString(); 
        const beratSekarang = (((this.txIndex % 10) + 1) * 10).toString();
        const umurSekarang = (((this.txIndex % 10) + 1) * 10).toString();
        const waktuPembaruan = (((this.txIndex % 10) + 1) * 10).toString();
        const konfirmasiVaksinasi = (((this.txIndex % 10) + 1) * 10).toString();
        const konfirmasiKelayakan = (((this.txIndex % 10) + 1) * 10).toString();
        const konfirmasiVaksinasiUpdatedAt = (((this.txIndex % 10) + 1) * 10).toString(); 
        const konfirmasiKelayakanUpdatedAt = (((this.txIndex % 10) + 1) * 10).toString(); 
        const arsipSertifikat = (((this.txIndex % 10) + 1) * 10).toString();

        const request = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'CreateAsset',
            invokerIdentity: 'User1',
            contractArguments: [earTag, jenisSapi, tanggalMasuk, beratAwal, arsipSapi, umurMasuk, beratSekarang, umurSekarang, waktuPembaruan, konfirmasiVaksinasi, konfirmasiKelayakan, konfirmasiVaksinasiUpdatedAt, konfirmasiKelayakanUpdatedAt, arsipSertifikat],
            readOnly: false
        };
        console.info(this.txIndex);
        await this.sutAdapter.sendRequests(request);
    }

}

function createWorkloadModule() {
    return new MyWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;