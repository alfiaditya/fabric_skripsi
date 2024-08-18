/*
 * SPDX-License-Identifier: Apache-2.0
 */
// Deterministic JSON.stringify()
import {Context, Contract, Info, Returns, Transaction} from 'fabric-contract-api';
import stringify from 'json-stringify-deterministic';
import sortKeysRecursive from 'sort-keys-recursive';
import { pencatatanSapi } from './pencatatanSapi';
var moment = require('moment');

@Info({title: 'RegistrySmartContract', description: 'Smart contract for registry Ternak'})
export class PencatatanSapiSmartContract extends Contract {
    
    // CreateAsset issues a new asset to the world state with given details.
    @Transaction()
    public async CreateAsset(ctx: Context, earTag: string, jenisSapi: string, tanggalMasuk: string, beratAwal: string, arsipSapi:string, umurMasuk:string, beratSekarang:string, umurSekarang:string, waktuPembaruan:string, konfirmasiVaksinasi:string, konfirmasiKelayakan:string, konfirmasiVaksinasiUpdatedAt:string, konfirmasiKelayakanUpdatedAt:string, arsipSertifikat:string ): Promise<any> {
        const exists = await this.AssetExists(ctx, earTag);
        if (exists) {
            throw new Error(`Aset dengan eartag ${earTag} tidak ditemukan.`);
        }

        const asset: pencatatanSapi = {
            earTag: earTag,
            jenisSapi: jenisSapi,
            tanggalMasuk: tanggalMasuk,
            beratAwal: beratAwal,
            arsipSapi: arsipSapi,
            umurMasuk: umurMasuk,
            beratSekarang: beratSekarang,
            umurSekarang: umurSekarang,
            waktuPembaruan: waktuPembaruan,
            konfirmasiVaksinasi: konfirmasiVaksinasi,
            konfirmasiKelayakan: konfirmasiKelayakan,
            konfirmasiVaksinasiUpdatedAt: konfirmasiVaksinasiUpdatedAt,
            konfirmasiKelayakanUpdatedAt: konfirmasiKelayakanUpdatedAt,
            arsipSertifikat: arsipSertifikat,
            createdAt: moment().format(),
        };

        // we insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
        await ctx.stub.putState(earTag, Buffer.from(stringify(sortKeysRecursive(asset))));
        const idTrx = ctx.stub.getTxID()
        return {"status":"success","idTrx":idTrx,"message":`Pencatatan Sapi Berhasil`}
    }

    // ReadAsset returns the asset stored in the world state with given id.
    @Transaction(false)
    public async ReadAsset(ctx: Context, earTag: string): Promise<string> {
        const assetJSON = await ctx.stub.getState(earTag); // get the asset from chaincode state
        if (!assetJSON || assetJSON.length === 0) {
            throw new Error(`The asset ${earTag} does not exist`);
        }
        return assetJSON.toString();
    }


    // AssetExists returns true when asset with given ID exists in world state.
    @Transaction(false)
    @Returns('boolean')
    public async AssetExists(ctx: Context, earTag: string): Promise<boolean> {
        const assetJSON = await ctx.stub.getState(earTag);
        return assetJSON && assetJSON.length > 0;
    }

    // GetAllAssets returns all assets found in the world state.
    @Transaction(false)
    @Returns('string')
    public async GetAllAssets(ctx: Context): Promise<string> {
        const allResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push(record);
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
    }


    


}