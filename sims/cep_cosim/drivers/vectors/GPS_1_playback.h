//************************************************************************
// Copyright 2022 Massachusetts Institute of Technology
//
// This file is auto-generated for test: GPS_1. Do not modify!!!
//
// Generated on: Aug 15 2022 14:11:08
//************************************************************************
#ifndef GPS_1_playback_H
#define GPS_1_playback_H

#ifndef PLAYBACK_CMD_H
#define PLAYBACK_CMD_H
// Write to : <physicalAdr> <writeData>
#define WRITE__CMD  1
// Read and compare: <physicalAdr> <Data2Compare>
#define RDnCMP_CMD  2
// Read and spin until match : <physicalAdr> <Data2Match> <mask> <timeout>
#define RDSPIN_CMD  3

#define WRITE__CMD_SIZE  3
#define RDnCMP_CMD_SIZE  3
#define RDSPIN_CMD_SIZE  5
#endif

// GPS_1 command sequences to playback
uint64_t GPS_1_playback[] = { 
	  WRITE__CMD, 0x70091038, 0x0000000000000001 // 1
	, WRITE__CMD, 0x70091038, 0x0000000000000001 // 2
	, WRITE__CMD, 0x70091038, 0x0000000000000001 // 3
	, WRITE__CMD, 0x70091038, 0x0000000000000001 // 4
	, WRITE__CMD, 0x70091038, 0x0000000000000001 // 5
	, WRITE__CMD, 0x70091038, 0x0000000000000000 // 6
	, WRITE__CMD, 0x70091030, 0x0000000000000000 // 7
	, WRITE__CMD, 0x70091040, 0xaaaaaaaaaaaaaaaa // 8
	, WRITE__CMD, 0x70091048, 0xaaaaaaaaaaaaaaaa // 9
	, WRITE__CMD, 0x70091050, 0xaaaaaaaaaaaaaaaa // 10
	, WRITE__CMD, 0x70091030, 0x0000000000000001 // 11
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 12
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 13
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 14
	, RDnCMP_CMD, 0x70091008, 0x0000000000001907 // 15
	, RDnCMP_CMD, 0x70091010, 0x924110552bd74e7f // 16
	, RDnCMP_CMD, 0x70091018, 0xc62d21cd7f83b3f9 // 17
	, RDnCMP_CMD, 0x70091020, 0x0609e8f9dc6348b0 // 18
	, RDnCMP_CMD, 0x70091028, 0xe718fdc8b191a85d // 19
	, WRITE__CMD, 0x70091040, 0x5555555555555555 // 20
	, WRITE__CMD, 0x70091048, 0x5555555555555555 // 21
	, WRITE__CMD, 0x70091050, 0x5555555555555555 // 22
	, WRITE__CMD, 0x70091030, 0x0000000000000002 // 23
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 24
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 25
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 26
	, RDnCMP_CMD, 0x70091008, 0x0000000000001c87 // 27
	, RDnCMP_CMD, 0x70091010, 0x800d9d1eb5ef85ca // 28
	, RDnCMP_CMD, 0x70091018, 0x7b25290c95bf1c92 // 29
	, RDnCMP_CMD, 0x70091020, 0x1c5c70ef948d4185 // 30
	, RDnCMP_CMD, 0x70091028, 0xbca1f30b29bf728b // 31
	, WRITE__CMD, 0x70091040, 0xb047733413013d16 // 32
	, WRITE__CMD, 0x70091048, 0xdf1610da2ebbfac0 // 33
	, WRITE__CMD, 0x70091050, 0x5b62b60e01434ec9 // 34
	, WRITE__CMD, 0x70091030, 0x0000000000000003 // 35
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 36
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 37
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 38
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e47 // 39
	, RDnCMP_CMD, 0x70091010, 0x892bdbbb7af3e010 // 40
	, RDnCMP_CMD, 0x70091018, 0xa5a12d6c60a14b27 // 41
	, RDnCMP_CMD, 0x70091020, 0x10ad1c482daf58bf // 42
	, RDnCMP_CMD, 0x70091028, 0x8249cf83d75fe1a9 // 43
	, WRITE__CMD, 0x70091040, 0x1620302d5abfa436 // 44
	, WRITE__CMD, 0x70091048, 0x44b4bf23253faae1 // 45
	, WRITE__CMD, 0x70091050, 0x7aadaa35b436eff2 // 46
	, WRITE__CMD, 0x70091030, 0x0000000000000004 // 47
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 48
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 49
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 50
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f27 // 51
	, RDnCMP_CMD, 0x70091010, 0x8db8f8e99d7dd2fd // 52
	, RDnCMP_CMD, 0x70091018, 0xcae32f5c1a2e60fd // 53
	, RDnCMP_CMD, 0x70091020, 0x9191ae192ebf7858 // 54
	, RDnCMP_CMD, 0x70091028, 0x501fcf9aaac2eaa8 // 55
	, WRITE__CMD, 0x70091040, 0xea48a9c545a54ddc // 56
	, WRITE__CMD, 0x70091048, 0x7431f035c087af26 // 57
	, WRITE__CMD, 0x70091050, 0xbc75f024ee72fad9 // 58
	, WRITE__CMD, 0x70091030, 0x0000000000000005 // 59
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 60
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 61
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 62
	, RDnCMP_CMD, 0x70091008, 0x00000000000012d8 // 63
	, RDnCMP_CMD, 0x70091010, 0x8ff16940eebacb8b // 64
	, RDnCMP_CMD, 0x70091018, 0x7d422e442769f510 // 65
	, RDnCMP_CMD, 0x70091020, 0x9643026382bc2aeb // 66
	, RDnCMP_CMD, 0x70091028, 0xe1b78e36f9f0f6d5 // 67
	, WRITE__CMD, 0x70091040, 0x86e920fca53c1323 // 68
	, WRITE__CMD, 0x70091048, 0x56a87ad9ca5f5530 // 69
	, WRITE__CMD, 0x70091050, 0x89893bd3149674d8 // 70
	, WRITE__CMD, 0x70091030, 0x0000000000000006 // 71
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 72
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 73
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 74
	, RDnCMP_CMD, 0x70091008, 0x0000000000001968 // 75
	, RDnCMP_CMD, 0x70091010, 0x8ed5a19457594730 // 76
	, RDnCMP_CMD, 0x70091018, 0x2692aec839ca3fe6 // 77
	, RDnCMP_CMD, 0x70091020, 0xf4713ed3c6388b49 // 78
	, RDnCMP_CMD, 0x70091028, 0x3bd9e93c527e9dcc // 79
	, WRITE__CMD, 0x70091040, 0x6bb450292101c6f9 // 80
	, WRITE__CMD, 0x70091048, 0xc23ca10fe4e7e1c4 // 81
	, WRITE__CMD, 0x70091050, 0xc509ae01048c96e0 // 82
	, WRITE__CMD, 0x70091030, 0x0000000000000007 // 83
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 84
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 85
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 86
	, RDnCMP_CMD, 0x70091008, 0x00000000000012cf // 87
	, RDnCMP_CMD, 0x70091010, 0x8e47c5fe0ba8816d // 88
	, RDnCMP_CMD, 0x70091018, 0x8b7aee8e369bda9d // 89
	, RDnCMP_CMD, 0x70091020, 0x8e35af30aa3f7ceb // 90
	, RDnCMP_CMD, 0x70091028, 0xf0c9b2b1b7bd8666 // 91
	, WRITE__CMD, 0x70091040, 0x0e6b71e0d54e2bcb // 92
	, WRITE__CMD, 0x70091048, 0xa78f47ecbb2daa2a // 93
	, WRITE__CMD, 0x70091050, 0xce86d7efc4e595e1 // 94
	, WRITE__CMD, 0x70091030, 0x0000000000000008 // 95
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 96
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 97
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 98
	, RDnCMP_CMD, 0x70091008, 0x0000000000001963 // 99
	, RDnCMP_CMD, 0x70091010, 0x8e0ef7cb25d06243 // 100
	, RDnCMP_CMD, 0x70091018, 0x5d8ecead31332820 // 101
	, RDnCMP_CMD, 0x70091020, 0x15770c4f2bd99233 // 102
	, RDnCMP_CMD, 0x70091028, 0x9b6e4d554190833c // 103
	, WRITE__CMD, 0x70091040, 0xf03d16180b651beb // 104
	, WRITE__CMD, 0x70091048, 0xddceb313f85e8d2e // 105
	, WRITE__CMD, 0x70091050, 0x9bd9e8f345b811e0 // 106
	, WRITE__CMD, 0x70091030, 0x0000000000000009 // 107
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 108
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 109
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 110
	, RDnCMP_CMD, 0x70091008, 0x0000000000001cb5 // 111
	, RDnCMP_CMD, 0x70091010, 0x8e2a6ed1b2ec13d4 // 112
	, RDnCMP_CMD, 0x70091018, 0x36f4debcb2e7517e // 113
	, RDnCMP_CMD, 0x70091020, 0xdb69796b537b2609 // 114
	, RDnCMP_CMD, 0x70091028, 0xa2507258e1c5e89e // 115
	, WRITE__CMD, 0x70091040, 0x04488fe25d671ee8 // 116
	, WRITE__CMD, 0x70091048, 0x444e161ece3c22d1 // 117
	, WRITE__CMD, 0x70091050, 0x8762f91739b9db29 // 118
	, WRITE__CMD, 0x70091030, 0x000000000000000a // 119
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 120
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 121
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 122
	, RDnCMP_CMD, 0x70091008, 0x0000000000001a25 // 123
	, RDnCMP_CMD, 0x70091010, 0x8e38225cf9722b1f // 124
	, RDnCMP_CMD, 0x70091018, 0x8349d6b4730d6dd1 // 125
	, RDnCMP_CMD, 0x70091020, 0x336928d0232ead52 // 126
	, RDnCMP_CMD, 0x70091028, 0x400979654178edc3 // 127
	, WRITE__CMD, 0x70091040, 0xd24ee512a3c32b15 // 128
	, WRITE__CMD, 0x70091048, 0xbc8350185532ead6 // 129
	, WRITE__CMD, 0x70091050, 0x74b5fa2a9c337fc0 // 130
	, WRITE__CMD, 0x70091030, 0x000000000000000b // 131
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 132
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 133
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 134
	, RDnCMP_CMD, 0x70091008, 0x0000000000001d16 // 135
	, RDnCMP_CMD, 0x70091010, 0x8e31041a5cbd377a // 136
	, RDnCMP_CMD, 0x70091018, 0x599752b013f87386 // 137
	, RDnCMP_CMD, 0x70091020, 0xae1d7ea80bdeb051 // 138
	, RDnCMP_CMD, 0x70091028, 0x6cfb52df567a61a6 // 139
	, WRITE__CMD, 0x70091040, 0x15753ffea638a0c0 // 140
	, WRITE__CMD, 0x70091048, 0xde974be4b11cf32a // 141
	, WRITE__CMD, 0x70091050, 0xa3aa112893a860fc // 142
	, WRITE__CMD, 0x70091030, 0x000000000000000c // 143
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 144
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 145
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 146
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f43 // 147
	, RDnCMP_CMD, 0x70091010, 0x8e3597390e5ab948 // 148
	, RDnCMP_CMD, 0x70091018, 0xb4f810b22382fcad // 149
	, RDnCMP_CMD, 0x70091020, 0x15b140b1ad82c263 // 150
	, RDnCMP_CMD, 0x70091028, 0x3b45b09ad9c6fc55 // 151
	, WRITE__CMD, 0x70091040, 0x76282ee7d985b129 // 152
	, WRITE__CMD, 0x70091048, 0x22c6a7c96fbd6afb // 153
	, WRITE__CMD, 0x70091050, 0xc0b6eff4736d4efd // 154
	, WRITE__CMD, 0x70091030, 0x000000000000000d // 155
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 156
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 157
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 158
	, RDnCMP_CMD, 0x70091008, 0x0000000000001fa5 // 159
	, RDnCMP_CMD, 0x70091010, 0x8e37dea8a7297e51 // 160
	, RDnCMP_CMD, 0x70091018, 0xc24fb1b33bbfbb38 // 161
	, RDnCMP_CMD, 0x70091020, 0x7dc6e827fd1336b9 // 162
	, RDnCMP_CMD, 0x70091028, 0x435100fd36ce0312 // 163
	, WRITE__CMD, 0x70091040, 0x5c46f439439b51e4 // 164
	, WRITE__CMD, 0x70091048, 0x252ecd18b37fb229 // 165
	, WRITE__CMD, 0x70091050, 0xe96eaf01227ba4e7 // 166
	, WRITE__CMD, 0x70091030, 0x000000000000000e // 167
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 168
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 169
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 170
	, RDnCMP_CMD, 0x70091008, 0x0000000000001fd6 // 171
	, RDnCMP_CMD, 0x70091010, 0x8e36fa6073909ddd // 172
	, RDnCMP_CMD, 0x70091018, 0x79146133b7a118f2 // 173
	, RDnCMP_CMD, 0x70091020, 0x21b5f9ab95648b37 // 174
	, RDnCMP_CMD, 0x70091028, 0x06bb60b03888610c // 175
	, WRITE__CMD, 0x70091040, 0xaa45171cd7535be9 // 176
	, WRITE__CMD, 0x70091048, 0x3d00c80c66691725 // 177
	, WRITE__CMD, 0x70091050, 0x1d67ad0a6d5dc8ef // 178
	, WRITE__CMD, 0x70091030, 0x000000000000000f // 179
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 180
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 181
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 182
	, RDnCMP_CMD, 0x70091008, 0x0000000000001fef // 183
	, RDnCMP_CMD, 0x70091010, 0x8e36680419cc6c1b // 184
	, RDnCMP_CMD, 0x70091018, 0x24b98973f1ae4917 // 185
	, RDnCMP_CMD, 0x70091020, 0x549e098e9a5437f0 // 186
	, RDnCMP_CMD, 0x70091028, 0x063f2bb3dd0a28a4 // 187
	, WRITE__CMD, 0x70091040, 0x80bb9332816f6adf // 188
	, WRITE__CMD, 0x70091048, 0x8e3d89177d351010 // 189
	, WRITE__CMD, 0x70091050, 0xfc2c8801859b4cfd // 190
	, WRITE__CMD, 0x70091030, 0x0000000000000010 // 191
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 192
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 193
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 194
	, RDnCMP_CMD, 0x70091008, 0x0000000000001ff3 // 195
	, RDnCMP_CMD, 0x70091010, 0x8e3621362ce214f8 // 196
	, RDnCMP_CMD, 0x70091018, 0x0a6f7d53d2a9e1e5 // 197
	, RDnCMP_CMD, 0x70091020, 0x668320aff41394ff // 198
	, RDnCMP_CMD, 0x70091028, 0x6ff21dd90a18afc7 // 199
	, WRITE__CMD, 0x70091040, 0x50f0c2d47d259122 // 200
	, WRITE__CMD, 0x70091048, 0x3e58ce07a1464306 // 201
	, WRITE__CMD, 0x70091050, 0xa821a50813a2273a // 202
	, WRITE__CMD, 0x70091030, 0x0000000000000011 // 203
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 204
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 205
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 206
	, RDnCMP_CMD, 0x70091008, 0x0000000000001370 // 207
	, RDnCMP_CMD, 0x70091010, 0x8e3605af36752889 // 208
	, RDnCMP_CMD, 0x70091018, 0x9d040743c32a359c // 209
	, RDnCMP_CMD, 0x70091020, 0x0b6a4f5d5346bcca // 210
	, RDnCMP_CMD, 0x70091028, 0x6b692167d8c1e1e8 // 211
	, WRITE__CMD, 0x70091040, 0xafb4e1d7279ff6f8 // 212
	, WRITE__CMD, 0x70091048, 0xebe8d5cfd1d0bbd0 // 213
	, WRITE__CMD, 0x70091050, 0x9d43752753b35ac9 // 214
	, WRITE__CMD, 0x70091030, 0x0000000000000012 // 215
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 216
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 217
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 218
	, RDnCMP_CMD, 0x70091008, 0x00000000000019bc // 219
	, RDnCMP_CMD, 0x70091010, 0x8e3617e3bb3eb6b1 // 220
	, RDnCMP_CMD, 0x70091018, 0x56b1ba4bcbebdfa0 // 221
	, RDnCMP_CMD, 0x70091020, 0x7ab04ff384025508 // 222
	, RDnCMP_CMD, 0x70091028, 0xf76eca623e651b8c // 223
	, WRITE__CMD, 0x70091040, 0x4035bcceadde6ed3 // 224
	, WRITE__CMD, 0x70091048, 0x7b95a7279f7695d9 // 225
	, WRITE__CMD, 0x70091050, 0xb936ccee7fbc74fd // 226
	, WRITE__CMD, 0x70091030, 0x0000000000000013 // 227
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 228
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 229
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 230
	, RDnCMP_CMD, 0x70091008, 0x0000000000001cda // 231
	, RDnCMP_CMD, 0x70091010, 0x8e361ec5fd9b79ad // 232
	, RDnCMP_CMD, 0x70091018, 0x336b64cfcf8b2abe // 233
	, RDnCMP_CMD, 0x70091020, 0xfdbe4ec4df293fd3 // 234
	, RDnCMP_CMD, 0x70091028, 0x4a529446d4487fe2 // 235
	, WRITE__CMD, 0x70091040, 0xb2a9c2eaa3cb8d38 // 236
	, WRITE__CMD, 0x70091048, 0xdc2ff3d9567c2ff7 // 237
	, WRITE__CMD, 0x70091050, 0x8df70714c459712b // 238
	, WRITE__CMD, 0x70091030, 0x0000000000000014 // 239
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 240
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 241
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 242
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e69 // 243
	, RDnCMP_CMD, 0x70091010, 0x8e361a56dec99e23 // 244
	, RDnCMP_CMD, 0x70091018, 0x01860b8dcdbb5031 // 245
	, RDnCMP_CMD, 0x70091020, 0x67d4dcd97128a98d // 246
	, RDnCMP_CMD, 0x70091028, 0xe443c2ec13893fee // 247
	, WRITE__CMD, 0x70091040, 0x59c464fb6d6bad0e // 248
	, WRITE__CMD, 0x70091048, 0x018cf52e3b9e2c2f // 249
	, WRITE__CMD, 0x70091050, 0xf36452bff5e05a02 // 250
	, WRITE__CMD, 0x70091030, 0x0000000000000015 // 251
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 252
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 253
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 254
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f30 // 255
	, RDnCMP_CMD, 0x70091010, 0x8e36181f4f60ede4 // 256
	, RDnCMP_CMD, 0x70091018, 0x18f0bc2ccca36d76 // 257
	, RDnCMP_CMD, 0x70091020, 0xf6f0674b11e7e263 // 258
	, RDnCMP_CMD, 0x70091028, 0xac15186bb49eec94 // 259
	, WRITE__CMD, 0x70091040, 0x485b43d25702db0b // 260
	, WRITE__CMD, 0x70091048, 0x8fac401628f10b0e // 261
	, WRITE__CMD, 0x70091050, 0x8992f7be397f191d // 262
	, WRITE__CMD, 0x70091030, 0x0000000000000016 // 263
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 264
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 265
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 266
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f9c // 267
	, RDnCMP_CMD, 0x70091010, 0x8e36193b87b45407 // 268
	, RDnCMP_CMD, 0x70091018, 0x944be7fc4c2f73d5 // 269
	, RDnCMP_CMD, 0x70091020, 0xe61bc143e60aedbd // 270
	, RDnCMP_CMD, 0x70091028, 0xdb094cc03294dfab // 271
	, WRITE__CMD, 0x70091040, 0x995ea21840c05d21 // 272
	, WRITE__CMD, 0x70091048, 0x66fdbf1d4d0888bd // 273
	, WRITE__CMD, 0x70091050, 0x983547e683d2540e // 274
	, WRITE__CMD, 0x70091030, 0x0000000000000017 // 275
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 276
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 277
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 278
	, RDnCMP_CMD, 0x70091008, 0x000000000000119e // 279
	, RDnCMP_CMD, 0x70091010, 0x8e3619a9e3de08f6 // 280
	, RDnCMP_CMD, 0x70091018, 0x52164a140c697c84 // 281
	, RDnCMP_CMD, 0x70091020, 0x19368f71e46c8172 // 282
	, RDnCMP_CMD, 0x70091028, 0x19dcce81ab53a954 // 283
	, WRITE__CMD, 0x70091040, 0x0a916222bcf7c438 // 284
	, WRITE__CMD, 0x70091048, 0x242e27fd6a9af7cf // 285
	, WRITE__CMD, 0x70091050, 0xf33ae7212efca6e0 // 286
	, WRITE__CMD, 0x70091030, 0x0000000000000018 // 287
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 288
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 289
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 290
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e34 // 291
	, RDnCMP_CMD, 0x70091010, 0x8e3619e0d1eb268e // 292
	, RDnCMP_CMD, 0x70091018, 0xb1389ce02c4a7b2c // 293
	, RDnCMP_CMD, 0x70091020, 0xe8100e96c9dab2bc // 294
	, RDnCMP_CMD, 0x70091028, 0xc79c2a6c466ecf7e // 295
	, WRITE__CMD, 0x70091040, 0xf61b282ee8f222de // 296
	, WRITE__CMD, 0x70091048, 0x35461ae1965e6e2a // 297
	, WRITE__CMD, 0x70091050, 0xcba44fe2285eb408 // 298
	, WRITE__CMD, 0x70091030, 0x0000000000000019 // 299
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 300
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 301
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 302
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f1e // 303
	, RDnCMP_CMD, 0x70091010, 0x8e3619c448f1b1b2 // 304
	, RDnCMP_CMD, 0x70091018, 0xc0aff79a3c5bf8f8 // 305
	, RDnCMP_CMD, 0x70091020, 0x43cdfefff7e01f57 // 306
	, RDnCMP_CMD, 0x70091028, 0xba94f8a15fa314e7 // 307
	, WRITE__CMD, 0x70091040, 0xe46fcf16757a3d35 // 308
	, WRITE__CMD, 0x70091048, 0x480a78044d0dcdc7 // 309
	, WRITE__CMD, 0x70091050, 0xb90f81d2d1c9d5fe // 310
	, WRITE__CMD, 0x70091030, 0x000000000000001a // 311
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 312
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 313
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 314
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f8b // 315
	, RDnCMP_CMD, 0x70091010, 0x8e3619d6047cfa2c // 316
	, RDnCMP_CMD, 0x70091018, 0xf864422734533912 // 317
	, RDnCMP_CMD, 0x70091020, 0x2e223f2e65016bb0 // 318
	, RDnCMP_CMD, 0x70091028, 0x94fe80d85ee09016 // 319
	, WRITE__CMD, 0x70091040, 0x4912d325ff7287c3 // 320
	, WRITE__CMD, 0x70091048, 0xdc8f4ed21411bacc // 321
	, WRITE__CMD, 0x70091050, 0x2357ac21a7fa7400 // 322
	, WRITE__CMD, 0x70091030, 0x000000000000001b // 323
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 324
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 325
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 326
	, RDnCMP_CMD, 0x70091008, 0x0000000000001fc1 // 327
	, RDnCMP_CMD, 0x70091010, 0x8e3619df223a5fe3 // 328
	, RDnCMP_CMD, 0x70091018, 0xe40198f9b05759e7 // 329
	, RDnCMP_CMD, 0x70091020, 0x3b905d5dd6f4196c // 330
	, RDnCMP_CMD, 0x70091028, 0x4efa822d49380447 // 331
	, WRITE__CMD, 0x70091040, 0x3537042794641805 // 332
	, WRITE__CMD, 0x70091048, 0xad4eafe36c3de60d // 333
	, WRITE__CMD, 0x70091050, 0x4d1ceaf98bbac027 // 334
	, WRITE__CMD, 0x70091030, 0x000000000000001c // 335
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 336
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 337
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 338
	, RDnCMP_CMD, 0x70091008, 0x0000000000001fe4 // 339
	, RDnCMP_CMD, 0x70091010, 0x8e3619dbb1190d04 // 340
	, RDnCMP_CMD, 0x70091018, 0x6a337596f255699d // 341
	, RDnCMP_CMD, 0x70091020, 0xc82393be4b90351f // 342
	, RDnCMP_CMD, 0x70091028, 0x927e0f253e688223 // 343
	, WRITE__CMD, 0x70091040, 0x3582b9e8d1ed70dc // 344
	, WRITE__CMD, 0x70091048, 0xdc87ec32682718c7 // 345
	, WRITE__CMD, 0x70091050, 0xc377a014cfa0c8fe // 346
	, WRITE__CMD, 0x70091030, 0x000000000000001d // 347
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 348
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 349
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 350
	, RDnCMP_CMD, 0x70091008, 0x00000000000012bc // 351
	, RDnCMP_CMD, 0x70091010, 0x8e3619d9f888a477 // 352
	, RDnCMP_CMD, 0x70091018, 0xad2a0321535471a0 // 353
	, RDnCMP_CMD, 0x70091020, 0xeed42f31c43f65d9 // 354
	, RDnCMP_CMD, 0x70091028, 0x54b6a7e5c917a796 // 355
	, WRITE__CMD, 0x70091040, 0x0c1280d97c14fd2c // 356
	, WRITE__CMD, 0x70091048, 0x092c9c1d25c9c5db // 357
	, WRITE__CMD, 0x70091050, 0xccba642410c6a4ee // 358
	, WRITE__CMD, 0x70091030, 0x000000000000001e // 359
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 360
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 361
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 362
	, RDnCMP_CMD, 0x70091008, 0x000000000000195a // 363
	, RDnCMP_CMD, 0x70091010, 0x8e3619d8dc4070ce // 364
	, RDnCMP_CMD, 0x70091018, 0x4ea6b87a83d4fdbe // 365
	, RDnCMP_CMD, 0x70091020, 0x1cd5bac7dbe605ee // 366
	, RDnCMP_CMD, 0x70091028, 0x991c26dfe20af29f // 367
	, WRITE__CMD, 0x70091040, 0xf4b484d6b06f36ea // 368
	, WRITE__CMD, 0x70091048, 0xb7eb9fef995fa1ec // 369
	, WRITE__CMD, 0x70091050, 0x6e0e8bd182fb77cc // 370
	, WRITE__CMD, 0x70091030, 0x000000000000001f // 371
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 372
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 373
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 374
	, RDnCMP_CMD, 0x70091008, 0x0000000000001ca9 // 375
	, RDnCMP_CMD, 0x70091010, 0x8e3619d84e241a92 // 376
	, RDnCMP_CMD, 0x70091018, 0xbf60e5d76b94bbb1 // 377
	, RDnCMP_CMD, 0x70091020, 0x958babf359b83506 // 378
	, RDnCMP_CMD, 0x70091028, 0xf771c7128f93dc86 // 379
	, WRITE__CMD, 0x70091040, 0x38b3df111cbfc4e4 // 380
	, WRITE__CMD, 0x70091048, 0x069171e7adae22d0 // 381
	, WRITE__CMD, 0x70091050, 0xa0c0d8dc164ebb2b // 382
	, WRITE__CMD, 0x70091030, 0x0000000000000020 // 383
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 384
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 385
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 386
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e50 // 387
	, RDnCMP_CMD, 0x70091010, 0x8e3619d807162fbc // 388
	, RDnCMP_CMD, 0x70091018, 0xc783cb019fb498b6 // 389
	, RDnCMP_CMD, 0x70091020, 0x8603b84973691c13 // 390
	, RDnCMP_CMD, 0x70091028, 0x0e3e79ab89beea0c // 391
	, WRITE__CMD, 0x70091040, 0xf8d7a1fa1f2434fc // 392
	, WRITE__CMD, 0x70091048, 0x3954d9ccfc047228 // 393
	, WRITE__CMD, 0x70091050, 0xd87c8cf449b45ae7 // 394
	, WRITE__CMD, 0x70091030, 0x0000000000000021 // 395
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 396
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 397
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 398
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f2c // 399
	, RDnCMP_CMD, 0x70091010, 0x8e3619d8238f352b // 400
	, RDnCMP_CMD, 0x70091018, 0xfbf25c6ae5a48935 // 401
	, RDnCMP_CMD, 0x70091020, 0xed5c41bc49d26e91 // 402
	, RDnCMP_CMD, 0x70091028, 0x24d8b01024b5ddbb // 403
	, WRITE__CMD, 0x70091040, 0x1ab5c9c2d94fdd10 // 404
	, WRITE__CMD, 0x70091048, 0x8e7775137c959cc3 // 405
	, WRITE__CMD, 0x70091050, 0xce9f70e37fca76e2 // 406
	, WRITE__CMD, 0x70091030, 0x0000000000000022 // 407
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 408
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 409
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 410
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e5b // 411
	, RDnCMP_CMD, 0x70091010, 0x8e3619d831c3b860 // 412
	, RDnCMP_CMD, 0x70091018, 0x65ca97df58ac81f4 // 413
	, RDnCMP_CMD, 0x70091020, 0x055577c7f59e7f47 // 414
	, RDnCMP_CMD, 0x70091028, 0x49c25d137c5f854e // 415
	, WRITE__CMD, 0x70091040, 0xbd3663343f15d1c0 // 416
	, WRITE__CMD, 0x70091048, 0x9d2d97e16602242a // 417
	, WRITE__CMD, 0x70091050, 0x8de5121d175954bf // 418
	, WRITE__CMD, 0x70091030, 0x0000000000000023 // 419
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 420
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 421
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 422
	, RDnCMP_CMD, 0x70091008, 0x00000000000012e1 // 423
	, RDnCMP_CMD, 0x70091010, 0x8e3619d838e5fec5 // 424
	, RDnCMP_CMD, 0x70091018, 0xaad6f20586288594 // 425
	, RDnCMP_CMD, 0x70091020, 0xbb44db95756fa58f // 426
	, RDnCMP_CMD, 0x70091028, 0xe7c082868e4b0d65 // 427
	, WRITE__CMD, 0x70091040, 0x22efa3cae2a56136 // 428
	, WRITE__CMD, 0x70091048, 0xda5990b79046d02c // 429
	, WRITE__CMD, 0x70091050, 0xf3d45b1d7cfbe0f7 // 430
	, WRITE__CMD, 0x70091030, 0x0000000000000024 // 431
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 432
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 433
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 434
	, RDnCMP_CMD, 0x70091008, 0x0000000000001974 // 435
	, RDnCMP_CMD, 0x70091010, 0x8e3619d83c76dd97 // 436
	, RDnCMP_CMD, 0x70091018, 0x4d58c0e8e96a87a4 // 437
	, RDnCMP_CMD, 0x70091020, 0x07391c6699eec7be // 438
	, RDnCMP_CMD, 0x70091028, 0xd49030ffd722491b // 439
	, WRITE__CMD, 0x70091040, 0x1e9bf4d552d8bec6 // 440
	, WRITE__CMD, 0x70091048, 0xf621a9cc48bd9c28 // 441
	, WRITE__CMD, 0x70091050, 0x8b3fc1eb51ddce3c // 442
	, WRITE__CMD, 0x70091030, 0x0000000000000025 // 443
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 444
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 445
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 446
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e5b // 447
	, RDnCMP_CMD, 0x70091010, 0x8e3619d83e3f4c3e // 448
	, RDnCMP_CMD, 0x70091018, 0x3e9fd99e5ecb86bc // 449
	, RDnCMP_CMD, 0x70091020, 0xb5ea70331604711c // 450
	, RDnCMP_CMD, 0x70091028, 0xb8bdc205b3b8d6a0 // 451
	, WRITE__CMD, 0x70091040, 0x23d59bbd3fc9c3fb // 452
	, WRITE__CMD, 0x70091048, 0x73105a0b751d961c // 453
	, WRITE__CMD, 0x70091050, 0xf7f2aed69b475907 // 454
	, WRITE__CMD, 0x70091030, 0x0000000000000001 // 455
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 456
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 457
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 458
	, RDnCMP_CMD, 0x70091008, 0x0000000000001907 // 459
	, RDnCMP_CMD, 0x70091010, 0x924110552bd74e7f // 460
	, RDnCMP_CMD, 0x70091018, 0xc62d21cd7f83b3f9 // 461
	, RDnCMP_CMD, 0x70091020, 0x40d3da3a7213fb5d // 462
	, RDnCMP_CMD, 0x70091028, 0x40ca39d10811cc75 // 463
	, WRITE__CMD, 0x70091030, 0x0000000000000000 // 464
	, WRITE__CMD, 0x70091040, 0x841865ea68eaabcd // 465
	, WRITE__CMD, 0x70091048, 0x746e5ec473f30e2b // 466
	, WRITE__CMD, 0x70091050, 0x2a195529d88b3636 // 467
	, WRITE__CMD, 0x70091060, 0x00005c22fee52078 // 468
	, WRITE__CMD, 0x70091058, 0x000000002aaab0a3 // 469
	, WRITE__CMD, 0x70091030, 0x0000000000000001 // 470
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 471
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 472
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 473
	, RDnCMP_CMD, 0x70091008, 0x0000000000001907 // 474
	, RDnCMP_CMD, 0x70091010, 0x5b01abdf2d263f34 // 475
	, RDnCMP_CMD, 0x70091018, 0x908af5d6c06af7cb // 476
	, RDnCMP_CMD, 0x70091020, 0x1f391b47ecd91e98 // 477
	, RDnCMP_CMD, 0x70091028, 0xd3e5410bc5ffa502 // 478
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 479
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 480
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 481
	, RDnCMP_CMD, 0x70091008, 0x0000000000000527 // 482
	, RDnCMP_CMD, 0x70091010, 0x498fcd2422bd75b0 // 483
	, RDnCMP_CMD, 0x70091018, 0x1abc641906411d0c // 484
	, RDnCMP_CMD, 0x70091020, 0x71cde5fbe6a178c4 // 485
	, RDnCMP_CMD, 0x70091028, 0xed525d235083ffe4 // 486
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 487
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 488
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 489
	, RDnCMP_CMD, 0x70091008, 0x0000000000001289 // 490
	, RDnCMP_CMD, 0x70091010, 0xa6db4d9f3de26e10 // 491
	, RDnCMP_CMD, 0x70091018, 0xc192b5c5c52b67cf // 492
	, RDnCMP_CMD, 0x70091020, 0x61667e2155e2a0c2 // 493
	, RDnCMP_CMD, 0x70091028, 0x01f117ffb8cd7404 // 494
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 495
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 496
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 497
	, RDnCMP_CMD, 0x70091008, 0x0000000000001ead // 498
	, RDnCMP_CMD, 0x70091010, 0x789b843064ad7170 // 499
	, RDnCMP_CMD, 0x70091018, 0x803c81679ddc92d6 // 500
	, RDnCMP_CMD, 0x70091020, 0x20ca38f5342834ee // 501
	, RDnCMP_CMD, 0x70091028, 0x74f973189ef0f841 // 502
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 503
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 504
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 505
	, RDnCMP_CMD, 0x70091008, 0x000000000000022a // 506
	, RDnCMP_CMD, 0x70091010, 0x4faf558a4d150984 // 507
	, RDnCMP_CMD, 0x70091018, 0x023114894462010c // 508
	, RDnCMP_CMD, 0x70091020, 0x9074fc008c2659e2 // 509
	, RDnCMP_CMD, 0x70091028, 0x6338cd438e2a3056 // 510
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 511
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 512
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 513
	, RDnCMP_CMD, 0x70091008, 0x0000000000001647 // 514
	, RDnCMP_CMD, 0x70091010, 0x854261008c44e8b4 // 515
	, RDnCMP_CMD, 0x70091018, 0x6a215b01abdf2d26 // 516
	, RDnCMP_CMD, 0x70091020, 0x72a218235fa14ff8 // 517
	, RDnCMP_CMD, 0x70091028, 0x8d116c3f119d6a58 // 518
};

#define GPS_1_adrBase 0x0070090000
#define GPS_1_adrSize 0x10000
#define GPS_1_cmdCnt4Single 19
#define GPS_1_totalCommands 518
#endif
