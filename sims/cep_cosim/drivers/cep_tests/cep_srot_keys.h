//************************************************************************
// Copyright 2021 Massachusetts Institute of Technology
// SPDX License Identifier: BSD-2-Clause
//
// File Name:      cep_srot.cc/h
// Program:        Common Evaluation Platform (CEP)
// Description:    SRoT class for CEP
// Notes:          
//************************************************************************

#ifndef cep_srot_keys_H
#define cep_srot_keys_H

#include "stdint.h"

#define INVERT_ALL_BITS  1
#define INVERT_ALTERNATE 2

// Include all core unlock keys here.
// Mock TSS keys are defined in llki_pkg.sv, and duplicated here.
const uint64_t  AES_MOCK_TSS_KEY[]     = {
  0xAE53456789ABCDEF,
  0xFEDCBA9876543210
};

const uint64_t  DES3_MOCK_TSS_KEY[]    = {
  0xDE53456789ABCDEF
};

const uint64_t  SHA256_MOCK_TSS_KEY[]  = {
  0x54A3456789ABCDEF,
  0xFEDCBA9876543210,
  0x0123456789ABCDEF,
  0xFEDCBA9876543210,
  0x0123456789ABCDEF,
  0xFEDCBA9876543210,
  0x0123456789ABCDEF,
  0xFEDCBA9876543210
};

const uint64_t  MD5_MOCK_TSS_KEY[]     = {
  0x3D53456789ABCDEF,
  0xFEDCBA9876543210,
  0x0123456789ABCDEF,
  0xFEDCBA9876543210,
  0x0123456789ABCDEF,
  0xFEDCBA9876543210,
  0x0123456789ABCDEF,
  0xFEDCBA9876543210
};

const uint64_t  RSA_MOCK_TSS_KEY[]     = {
  0x45A3456789ABCDEF
};

const uint64_t  IIR_MOCK_TSS_KEY[]     = {
  0x1143456789ABCDEF
};

const uint64_t  FIR_MOCK_TSS_KEY[]     = {
  0xF143456789ABCDEF
};

const uint64_t  DFT_MOCK_TSS_KEY[]     = {
  0xDF73456789ABCDEF
};

const uint64_t  IDFT_MOCK_TSS_KEY[]    = {
  0x1DF7456789ABCDEF
};

const uint64_t  GPS_MOCK_TSS_KEY[]     = {
  0x6953456789ABCDEF,
  0xFEDCBA9876543210,
  0x0123456789ABCDEF,
  0xFEDCBA9876543210,
  0x0123456789ABCDEF
};

// Configuration bitstream for the CMU-redacted GPS core
// Per CEPConfigs.scala, it is @ gps_1_base_address
// (which corresponds to core index 12)
const uint64_t  CMU_GPS_TSS_KEY[]       = {
  0x0124924924924924,
  0x9249249249249249,
  0x2492492492492492,
  0x4924924924924924,
  0x9249249249249249,
  0x2492492492492492,
  0x48AB2034FA017923,
  0x6B603B5342F62369,
  0x112112C088B0305C,
  0x00D7AFBBC0547012,
  0x3EAFBE133D27FE38,
  0x3FF80C4BFFD193D2,
  0x93E7E2E2E2C8889A,
  0xCACB3F001111BCF0,
  0x1FC30FFF33F47C2B,
  0x8E9BFE8BFEBF3D20,
  0x123A12BCA330305A,
  0x65B4444FBBBB5050,
  0x659A521EDC014213,
  0x3C27FE283FE8158B,
  0xFFD393D093E7E1B8,
  0xB8C888ACACABF030,
  0x1111BCF01FC30FFF,
  0x33A1B53FD0015300,
  0x10082C0800090009,
  0x10FE00956AB10151,
  0x00030415C0517AEB,
  0xFC0517CFBDBE7C15,
  0x9D8BFDBF3FE03E82,
  0x13CCA33030FEBE96,
  0x996D1113505070F0,
  0xD41EBC00C37070BB,
  0x8C67FFE7E71BFE3D,
  0x0520133FF6040048,
  0x003EEEECCC03EEEE,
  0x800150020D5403E0,
  0xBC006BE33D4BCFC5,
  0x8BF792BE93D3E330,
  0x309A65B30303B800,
  0xF0C0BCF01FA50FFF,
  0x31ABDDAFFDAFF0B8,
  0xBC73FE99EBE610CB,
  0x2EEE448888AEE44B,
  0x2B2A666620002000,
  0x3000219AB3F7CEB3,
  0xFEBFE620843C2328,
  0x52BFED0002FFF33E,
  0xEEEFFEA980008001,
  0x50040D540348BFCA,
  0xAA8ABE88FF2A7FF9,
  0xAFF19DBE5EE2E2BF,
  0x0C2E2E2AE2E2ACAC,
  0xBC332FC30ABE83E0,
  0x67E337E2907FD7E2,
  0x0F13FFE2133FE2F3,
  0xC0BCF02F3C000155,
  0xF3C0FBBB9FC30D54,
  0x03FFFFFFFFFFFFFF,
  0xFFFFFFFFFFFFFFFF,
  0xFF0000C00030000C,
  0x00030000C0003000,
  0x0C0003FF9775BE8B,
  0x3FF4579ABFF453F7,
  0x13D3E20FF0AE2E2E,
  0x4E4BF0C0E0E0BCF0,
  0x1FC30CCC0202A94F,
  0xFDBF3C1778F99203,
  0xFED041A1140010C8,
  0x88BFAFA400056996,
  0x599991441EFFFFF3,
  0xBFF33C374D1D3FCA,
  0x7FF07F9213F3D7FC,
  0xFCCC0C0800080407,
  0x0C0CFF3F00020CCC,
  0x00C20830A023A029,
  0x090AA8206C80A284,
  0x88B212EA18090899,
  0x101C40F6C07B6558,
  0x1E8205E02C0F0CB2,
  0x8028400C07172051,
  0x67130BDB0C041430,
  0x50E34C9DD2015247,
  0x2011D4881804002C,
  0xD80077C444D43804,
  0x80130B0200007900,
  0xF02900AA0C828340,
  0x0002947850540880,
  0x8B16A15002AAAC05,
  0x4004260419549244,
  0x1014052005D54641,
  0x411A511710150065,
  0xE612000018232038,
  0x01680143145A030C,
  0x8020042F00365967,
  0x002AC8E410516F7E,
  0x824CC0027806180C,
  0xC840804080280000,
  0x40045028DFA09BB0,
  0x19E01802F00010BE,
  0x8F60382C924C20A0,
  0x2A7B2932D42CD248,
  0x9828101262B600C2,
  0x0000000000000800,
  0x0200000000000004,
  0x6000110000600004,
  0x00000202E0004059,
  0x8003E12A5B1B650D,
  0x3023000000000000,
  0x0000000000000004,
  0x0000000800510000,
  0x0984000000730000,
  0xDD84028000406C00,
  0x0E1D467B0000030C,
  0x0000209F5F1C0000,
  0x1C00000000000401,
  0x64C19C0580010800,
  0x805015A901004000,
  0xB8217A6247400692,
  0x08C30086028EAE00,
  0x0001000000000000,
  0xC07006E0202E005C,
  0x001C0000E09FD200,
  0x0028005000018D00,
  0x00000B180005F4BA,
  0x3100000000000000
};

const uint64_t  CMU_SHA256_TSS_KEY[]    = {
  0x0000000000000048,
  0x0000000000000048,
  0x0000000048448000,
  0x0000000000000048,
  0x2095BDB6EF7DD9DD,
  0x2095BDA6A6994994,
  0x0004248200000200,
  0x20919924A6194995,
  0xBDBFFFFFFF3FFFFF,
  0x992D249249A49249,
  0x0001249249649249,
  0x9D2E424910822422,
  0xFFFE492492492492,
  0x24936DB6DB6DB6DB,
  0x2492DB6DB6DB6DB6,
  0x4240000000000000,
  0x4924924924924924,
  0x6DB6DB6DB6DB6DB6,
  0xDB6DB6DB6DB6DB6D,
  0x0000000000000000,
  0x9249249249249249,
  0xDB6DB6DB6DB6DB6D,
  0xB6DB6DB6DB6DB6DB,
  0x0000000000000000,
  0x2492492492492492,
  0xB6DB6DB6DB6DB6DB,
  0x6DB6DB6DB6DB6DB6,
  0x0000000000000000,
  0x4924924924924924,
  0x6DB6DB6DB6DB6DB6,
  0xDB6DB6DB6DB6DB6D,
  0x0000000000000000,
  0x9249249249249249,
  0xDB6DB6DB6DB6DB6D,
  0xB6DB6DB6DB6DB6DB,
  0x0000000000000000,
  0x2492492492492492,
  0xB6DB6DB6DB6DB6DB,
  0x6DB6DB6DB6DB6DB6,
  0x0000000000000000,
  0x4924924924924924,
  0x6DB6DB6DB6DB6DB6,
  0xDB6DB6DB6DB6DB6D,
  0x0000000000000000,
  0x9249249249249249,
  0xDB6DB6DB6DB6DB6D,
  0xB6DB6DB6DB6DB6DB,
  0x0000000000000000,
  0x2492492492492492,
  0xB6DB6DB6DB6DB6DB,
  0x6DB6DB6DB6DB6DB6,
  0x0000000000000000,
  0x4924924924924924,
  0x6DB6DB6DB6DB6DB6,
  0xDB6DB6DB6DB6DB6D,
  0x0000000000000000,
  0x9249249249249249,
  0xDB6DB6DB6DB6DB6D,
  0xB6DB6DB6DB6DB6DB,
  0x0000000000000000,
  0x2492492492492492,
  0xB6DB6DB6DB6DB6DB,
  0x6DB6DB6DB6DB6DB6,
  0x0000000000000000,
  0x4924924924924924,
  0x6DB6DB6DB6DB6DB6,
  0xDB6DB6DB6DB6DB6D,
  0x0000000000000000,
  0x9249249249249249,
  0xDB6DB6DB6DB6DB6D,
  0xB6DB6DB6DB6DB6DB,
  0x0000000000000000,
  0x2492492492492492,
  0xB6DB6DB6DB6DB6DB,
  0x6DB6DB6DB6DB6DB6,
  0x0000000000000000,
  0x4924924924924928,
  0x6DB6DB6DB6DB6DBA,
  0xDB6DB6DB6DB6DB6D,
  0x0000000000000000,
  0x9249249249249245,
  0xDB6DB6DB6DB6DB6D,
  0xB6DB6DB6DB6DB6D7,
  0x0000000000000000,
  0x2924924924924928,
  0xBB6DB6DB6DB6DB6D,
  0x6DB6DB6DB6DB6DBA,
  0x0000000000000000,
  0x444A249289249247,
  0x6D6EB6DBADB6DB69,
  0xD6DB6DB6DB6DB6D1,
  0x0000000000000000,
  0x311109242449492A,
  0x755B6DB6AD6DDB69,
  0xBB359B6D36DB6DB8,
  0x1000000000000000,
  0x9A2A928A8A941486,
  0xBB3B9BAEAEDD5DA8,
  0xDE6EB6DB9BB6B6D5,
  0x1080000040000000,
  0x104008102042216C,
  0xAA2AD2AA8A941488,
  0x6515256515298A1A,
  0x2080402040006049,
  0x849A110CCB16899C,
  0x418D408A503A630B,
  0x53CC0C9B705B674B,
  0x20A0A32044A0502D,
  0x2644D48748C782C0,
  0x45AA7B1C76B4D3B5,
  0xD5BA7B3C7794FFBF,
  0x08AA8A4816081031,
  0xB6204125A1256F68,
  0x6331973144398A04,
  0x6374B7B3CCFB9A84,
  0x088B0C48122C0053,
  0x4B22334999E914E8,
  0x1A5120C20D64800E,
  0x9EC069C62F46B01E,
  0x080C865040304A03,
  0x95A09E4356A52372,
  0x194D7395B8D71ACD,
  0x5B4F739DB8DFDFCD,
  0x204520B489100805,
  0x570C0A101095F750,
  0x4D9A530923181049,
  0xCDAAD74B7778186B,
  0x205130A4890204C4,
  0xA8C182AB74D03D46,
  0x2913226C01A6A6C3,
  0x79056A7C838FA6F3,
  0x22281420182240CC,
  0xE0A8F066925B0931,
  0x8B359E3A6BB1CB9E,
  0x9B759EBA6F91FFDE,
  0x071127082884408A,
  0x324488A38C30AE78,
  0x68666432492D0804,
  0xE8EC7477DB6F5805,
  0x05134B0820B403A2,
  0x6550111BC762568A,
  0xA5AA2B0C0D340320,
  0xAFA0AF8C3D1D4361,
  0x2425612080A0A906,
  0x6C430C86792B82F8,
  0xE185C72BCEA6ABA6,
  0xE395D73BCEE6FFB7,
  0x30E4696884900804,
  0x2F0190225281F9F1,
  0xC5592A1318B42104,
  0xC5732E9779FC250C,
  0x988C7148841303A0,
  0x106240D6CAD42D49,
  0x1988514807134B25,
  0x7A81D9692633DB35,
  0x94142240510E0382,
  0x509B614B40F0380D,
  0x2E2EBA66B59CAEB8,
  0xAE6EBAE6BC9FEFF8,
  0x26308E2092080493,
  0x8841229631AFD90A,
  0x4D1630C31B309043,
  0x5C9E71DB5F70B247,
  0x23228C2083800C32,
  0x141894732F42B212,
  0x610C1D0163880124,
  0xA84D3F05E2B8292D,
  0x02A204A8190144E0,
  0x3909AD12E076592B,
  0x96EE96E63A59764E,
  0x96FE96EE3FDDF65E,
  0xA2A252C1100102E0,
  0x0458202A2BFD8489,
  0x6824848D300088E2,
  0x392D8D9DF002C9B6,
  0xC2E252410440A680,
  0x13055713D14DC22D,
  0x4184D81A6511A48A,
  0x05D4F8BA6F13A59A,
  0xA82240440480B802,
  0x0AC466E29A2EC534,
  0xE732BB34D39569E8,
  0xF733BB35F7F56BA9,
  0x611A890C00811842,
  0x144120A0F7E41922,
  0xA662323D1A125243,
  0xAEE6767F1A1AD617,
  0x6118890C08913088,
  0x436C1C50668344B4,
  0x8958841934A1A66B,
  0x995B86B9B5E5BE6B,
  0xADA825064C182389,
  0x1506567986C55502,
  0x25ADA7CE5F29C5A2,
  0x67BDAFCE7F2BEDE6,
  0x9D80A48705180319,
  0x086447215C42AEF6,
  0x5032290860711471,
  0x7333391AEAF51471,
  0x880C82E5191A001E,
  0x71E3E18293F09265,
  0x881C0275013A240A,
  0xAA3D57774FBE64EA,
  0xE40BA84A93899309,
  0x77DC11664B3476AB,
  0x0804A24A95098202,
  0x0E45A7CAD7FDCB06,
  0xC712510D4B0524F8,
  0x39E5665605A96F13,
  0xC0025019B8900068,
  0xD48E553BAA92DBE8,
  0x897226D514696146,
  0x7252F320A49BCAF1,
  0x85908DF50060620E,
  0xA591C9F503E6FE8F,
  0x420EA482B45889C4,
  0xE89019B99356F23B,
  0x100FA08E650881C0,
  0x105FA3AE4F2FD9D0,
  0xCC880C5BA2D2170A,
  0xA781AD874F2C58F4,
  0x696A2C5884D81708,
  0x69623CF89DFD3F28,
  0x1799034760A4CCC5,
  0x68372CB4FC5D35B6,
  0x158453833030E208,
  0xB584EBABBF39F24C,
  0x523F12748CC19D87,
  0xC5CA6AA83938A368,
  0x06D50A5600CA8C89,
  0x2ED58EDFF7CFBCDD,
  0xD26A516809B04B61,
  0x3691DA97A75FAAA5,
  0xD06B11B4AD54EB25,
  0xF1EABB218919E10B,
  0x2E25C5DF74E75EF4,
  0xB44A79238B13E10B,
  0xAECF4DFD7CF51F7D,
  0x9E9818218910A101,
  0x6967C7DC74ED1EFC,
  0x9C892CFDBDB2B557,
  0x69EBC794952BA4DC,
  0x8C0008B50C108105,
  0x63FFD702D36F6EF8,
  0xD9424BFC2C89908F,
  0x93DF5D22F3EE7EF2,
  0x884001B404809006,
  0x37BFFC03F37E6FF0,
  0xC2D507F495C57A5F,
  0x7737EC95B45D4BCC,
  0xC05101B00080184A,
  0x3F2EFC0FFE7FC7AC,
  0xF4B3A9F101082943,
  0x3E8CBC2FFE77C62C,
  0x7411089120900848,
  0x2BCCF62EDE7FD634,
  0xBC001C1FE166EF61,
  0x21C0E3E00989101C,
  0x341209CD418B004C,
  0x23E4E678689238D0,
  0x1CDB89800181C7A5,
  0x1220151610003802,
  0x7112151E56027843,
  0x82644BC188194014,
  0x32B99CDB1F635812,
  0x8D424204C0104055,
  0x1DC120642284605D,
  0x878742C8C2501017,
  0xB84830008412B768,
  0x0202058E44C00002,
  0x02AF15CA0EDCA082,
  0xFD40D8151180F76D,
  0xBEEC9D8D6E150180,
  0x0508D81011E8502A,
  0x04099A0000ECB2AA,
  0xC110CC90134809D4,
  0x441E6542A5B77321,
  0x428162A412000844,
  0x6EED62B002008600,
  0xD103770015EA28D6,
  0x6EE16033A103512D,
  0x130475045802AED2,
  0x0A6465097806AE40,
  0x9380CAA70028C4D2,
  0x3DF17D0D7DE2AA31,
  0x40042081003D4004,
  0x04463249003D4127,
  0xC4D891804329BEF8,
  0x0100040EC4D6C9ED,
  0x42958300010018A8,
  0xD7D1D34483002BA8,
  0x20268AA5C4DF90CC,
  0x579C12500E002D06,
  0x2023E881404F1240,
  0x1001E044C24F4A50,
  0x2026A9A22AA09624,
  0xB17B5ECDC26D6400,
  0x4C8403A221089024,
  0x4804029010085005,
  0x5093F126289C88DA,
  0x8B2F93C23655E1AD,
  0x14C0403DC9201852,
  0x30C94AFCC010B281,
  0x4E01211948B6E8D2,
  0x2B2168B0A0000600,
  0x000101070D2C5161,
  0x308101461EBCF7E8,
  0x0C1848BAE5420215,
  0xC00ECAADDB9977EB,
  0x9800151140460254,
  0xB852947160000640,
  0x5683D88F1E460875,
  0xD81404A94880C1BD,
  0x0761490131040000,
  0x2172C840FB142C92,
  0x0EA035BD2C6603B5,
  0x035BD46AFBBD1C03,
  0x088220140C40A364,
  0xA8861A000A10ADF6,
  0x03F03414056E280B,
  0x284602A20791CF77,
  0x80100C00102E1208,
  0x80D25E45026E5280,
  0x156929101B92B428,
  0xA57E5D0480CBE200,
  0x11612270091001E0,
  0x0360026423590BE9,
  0x51312DB950E67496,
  0x2A115056BBCA5B7D,
  0x0008AF8143200506,
  0x40888F8003900105,
  0x005910F944A60546,
  0x50008549C329A2C3,
  0x0051228C0C120400,
  0x641308EE0F924A00,
  0x89ACF659D4340642,
  0x37632EF60AFB801A,
  0xC8B45051D0001D40,
  0x24228871D1041F40,
  0xC88454141E23A8BF,
  0x20A930244D6C175E,
  0xC0908E00B003A0A5,
  0xC9A39E28A003E204,
  0x121CD1C4C2243CA1,
  0xAF8B8A0029D283D7,
  0x100408E450200410,
  0x480218244060E414,
  0x30644E9BBC089003,
  0x82CF92D4F042F430,
  0x6520242A04009003,
  0x651091A00A249803,
  0xD12076CB04491610,
  0x66D1800110980450,
  0x900C2A651840080A,
  0x980E7ACDBB480B0C,
  0x17F405334C2F8471,
  0x9C1BDAED33000ACC,
  0x13E2051244018412,
  0x1AE230482B080630,
  0x152D1D52C4475B4A,
  0xDCAF02374D98AEEB,
  0x1300288092454100,
  0x1B127AC05A201022,
  0xCC402734A2474D50,
  0x734187C39D80528A,
  0x5000073460310C52,
  0xD8100734603F1CDA,
  0x068005C03FD0D115,
  0x404A08A0212F12DA,
  0x2E00004C4CC08005,
  0x6E0160485EC02000,
  0x09A012F02178C925,
  0xBD00981B1CFE16EB,
  0x202002A46B00E810,
  0x201540A02B02A001,
  0x26A2254E421F691B,
  0x9D7D41A04962CA66,
  0x028210A4001F0018,
  0x000564A4B31F0719,
  0x468A324E0161A802,
  0x593508A02E108C17,
  0x24E8500010682008,
  0x24EC51A25B608A88,
  0x5B5784559E8B3D03,
  0xA1BD7DAEDAC1500C,
  0x5A028051888AA572,
  0xDE000000C8B08E76,
  0x03E2825180C151A9,
  0xA801091045582C5E,
  0x0D00000A0027F481,
  0x6D92A44B0025F688,
  0x14441280387820F9,
  0x63D2D14E24052612,
  0x10040208284AE000,
  0x8403046832484C0A,
  0x582C2A8BE0A7A167,
  0x17A197369B9732EB,
  0xE80A684140030003,
  0xE403462012634803,
  0x89B86AE340082505,
  0xBC0FA000C8539180,
  0x01B00C4A040C6000,
  0x41B00EEB040F6B00,
  0x241BF404F980C416,
  0x23942B6BC62E4A10,
  0x046BD00410880506,
  0x4449D08100489328,
  0x24925E16398D24C5,
  0x135C1D705276DE3B,
  0x20A29087A8812190,
  0x6886B1878060991C,
  0x847041F8ADA52CC9,
  0x6804A3876E438050,
  0x80000178048C17C5,
  0x4C01117817AC1EFD,
  0x80D2408DA403E346,
  0x60711A7CA1343D8D,
  0x00004000000BE542,
  0x010162090083E550,
  0x9E07834C920C72CA,
  0x75F570D353844524,
  0x8A03010480498018,
  0x0101220D80498D18,
  0x8A0AC04347969272,
  0x030649E1A4A95C1C,
  0x0060160003860202,
  0xE462342403C60081,
  0x1089D84A441BE202,
  0xE76885A7F8A2B239,
  0x10C34A5013480000,
  0x0852C8C893C80400,
  0x10E097116D5549C6,
  0x52B955E002AAB52D,
  0x04021811EC054882,
  0x28929A80EC700400,
  0x84BC28B907854882,
  0x2900B0DFA66A6708,
  0x846B22A008148000,
  0x2CF9F2A000144000,
  0x80028A1D9985D851,
  0x9851A22097132F74,
  0x0000001D29C8901B,
  0x4000000D22CA401A,
  0x040C5090BB97908B,
  0x5C10447043CDD870,
  0x014F38AD9A4022C2,
  0xA1020800924223D7,
  0x416F383D28CDDCAA,
  0x3C149110909E2315,
  0xC1472A1D0900DD22,
  0xC3636A8509055D07,
  0x81472A1D0B0E86BE,
  0x3E20459001919507,
  0x01479A08E2EA52B8,
  0x41874812204F7198,
  0x09569A18E1A182BB,
  0x1437691300076208,
  0xC9DC9218E02012B3,
  0xC9DC9618E0209993,
  0xC6D59218E02002B0,
  0x090F7748C01581B2,
  0x8640884323A87A91,
  0x8620885023C89298,
  0x8BC9C02B23A86AD1,
  0x0380296478018302,
  0x8809651B03B87AB3,
  0xCC09575B03A8FBB9,
  0x83F0A81303B86BB1,
  0x240946293800908A,
  0xCBA2214043B80082,
  0xCBA2004003A885A2,
  0xC02821C047981000,
  0xC8800000046005C2,
  0x400021C0429A992E,
  0x400001C0018089A4,
  0xC8002140423A182E,
  0x0800894081A40482,
  0xD10861E0601A190E,
  0xD10C40E0201A192E,
  0x510861E063BA190E,
  0x80300319008116A9,
  0x51086160612D9CAC,
  0x514C61E6613CFC1C,
  0x51087160E2C309E6,
  0x8A57AD52517CDE1D,
  0x995CE97271AF43E7,
  0x155CE13030AC540D,
  0xF90858E6EB4323E2,
  0x25FFE73934FB54BF,
  0xEC811CCFCD8236A8,
  0x2055A5191428400D,
  0xDE8018C6CB86BFE0,
  0xE9575EBFB559221E,
  0x9FD252A2A3D7BDE2,
  0xA941060B8441000A,
  0x16BAF1E06BB6FDE1,
  0xEFC40E1B92C714D6,
  0x443EF5F07B327455,
  0x8944021280430002,
  0x543BF5E47F30FD7D,
  0xABAEAAFAA9620082,
  0xFEABAEAEBF409D7C,
  0xAA86823A09176000,
  0x54797D85F6C09D7C,
  0xFF87867E1D37E156,
  0x00787981E0C00042,
  0xAA82822A0B001C63,
  0x00787981E0C00008
};

const uint64_t  CMU_GPS_LBLL_TSS_KEY[]    = {
  0x22C3FA22862F0100,
  0x2839C91417392A65,
  0x14C02A684001C199,
  0x381148149B0EF430
};


//Key info struct for unlocking LLKI cores.
typedef struct cep_key_info_t {
    const char      *name;              //
    const uint64_t  *keyData;           // Actual Key Bits
    const uint64_t  lowPointer;         // Lower bound of where key will be loaded into KeyRAM
    const uint64_t  highPointer;        // Upper bound of where key will be loaded into KeyRAM
    const int       invertType;         // 
} cep_key_info_t;

// Number of LLKI cores for MacroMix to cover. 
// Don't include SROT or CEP Version "cores", which must be the last ones in this list.
#define CEP_LLKI_CORES 16
    
//
// Array of keys and key lengths (number of 64 bit words)
// index in array == core index
// The order defined here **MUST** correspond to those
// defined in DevKitConfigs.scala
//
// KeyLength = High Pointer - Low Pointer + 1
//
const cep_key_info_t KEY_DATA[CEP_LLKI_CORES] = {
  {"AES",      AES_MOCK_TSS_KEY,        0,   1,   INVERT_ALL_BITS},
  {"MD5",      MD5_MOCK_TSS_KEY,        2,   9,   INVERT_ALL_BITS},
  {"SHA256.0", CMU_SHA256_TSS_KEY,     10,  517,  INVERT_ALL_BITS}, // CMU Core
  {"SHA256.1", SHA256_MOCK_TSS_KEY,   518,  525,  INVERT_ALL_BITS},
  {"SHA256.2", SHA256_MOCK_TSS_KEY,   526,  533,  INVERT_ALL_BITS},
  {"SHA256.3", SHA256_MOCK_TSS_KEY,   534,  541,  INVERT_ALL_BITS},
  {"RSA",      RSA_MOCK_TSS_KEY,      542,  542,  INVERT_ALL_BITS},
  {"DES3",     DES3_MOCK_TSS_KEY,     543,  543,  INVERT_ALL_BITS},
  {"DFT",      DFT_MOCK_TSS_KEY,      544,  544,  INVERT_ALL_BITS},
  {"IDFT",     IDFT_MOCK_TSS_KEY,     545,  545,  INVERT_ALL_BITS},
  {"FIR",      FIR_MOCK_TSS_KEY,      546,  546,  INVERT_ALTERNATE},
  {"IIR",      IIR_MOCK_TSS_KEY,      547,  547,  INVERT_ALTERNATE},
  {"GPS.0",    CMU_GPS_LBLL_TSS_KEY,  548,  551,  INVERT_ALL_BITS}, // CMU Core
  {"GPS.1",    CMU_GPS_TSS_KEY,       552,  677,  INVERT_ALL_BITS},
  {"GPS.2",    GPS_MOCK_TSS_KEY,      678,  682,  INVERT_ALL_BITS},
  {"GPS.3",    GPS_MOCK_TSS_KEY,      683,  687,  INVERT_ALL_BITS}
};

#endif
