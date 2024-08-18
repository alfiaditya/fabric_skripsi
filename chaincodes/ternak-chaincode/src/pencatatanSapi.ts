/*
  SPDX-License-Identifier: Apache-2.0
*/

import {Object, Property} from 'fabric-contract-api';

@Object()
export class pencatatanSapi {
    @Property()
    public earTag: string;
 
    @Property()
    public jenisSapi: string;

    @Property()
    public tanggalMasuk: string;

    @Property()
    public beratAwal: string;

    @Property()
    public arsipSapi: string;

    @Property()
    public umurMasuk: string;

    @Property()
    public beratSekarang: string;

    @Property()
    public umurSekarang: string;

    @Property()
    public waktuPembaruan: string;

    @Property()
    public konfirmasiVaksinasi: string;

    @Property()
    public konfirmasiKelayakan: string;

    @Property()
    public konfirmasiVaksinasiUpdatedAt: string;
    
    @Property()
    public konfirmasiKelayakanUpdatedAt: string;
    
    @Property()
    public arsipSertifikat: string;
    
    @Property()
    public createdAt: string;

}