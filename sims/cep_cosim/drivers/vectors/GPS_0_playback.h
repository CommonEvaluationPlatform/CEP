//************************************************************************
// Copyright 2022 Massachusetts Institute of Technology
//
// This file is auto-generated for test: GPS_0. Do not modify!!!
//
// Generated on: May 18 2023 08:49:19
//************************************************************************
#ifndef GPS_0_playback_H
#define GPS_0_playback_H

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

// GPS_0 command sequences to playback
uint64_t GPS_0_playback[] = { 
	  WRITE__CMD, 0x70090038, 0x0000000000000001 // 1
	, WRITE__CMD, 0x70090038, 0x0000000000000001 // 2
	, WRITE__CMD, 0x70090038, 0x0000000000000001 // 3
	, WRITE__CMD, 0x70090038, 0x0000000000000001 // 4
	, WRITE__CMD, 0x70090038, 0x0000000000000001 // 5
	, WRITE__CMD, 0x70090038, 0x0000000000000000 // 6
	, WRITE__CMD, 0x70090030, 0x0000000000000000 // 7
	, WRITE__CMD, 0x70090040, 0xaaaaaaaaaaaaaaaa // 8
	, WRITE__CMD, 0x70090048, 0xaaaaaaaaaaaaaaaa // 9
	, WRITE__CMD, 0x70090050, 0xaaaaaaaaaaaaaaaa // 10
	, WRITE__CMD, 0x70090030, 0x0000000000000001 // 11
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 12
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 13
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 14
	, RDnCMP_CMD, 0x70090008, 0x0000000000001907 // 15
	, RDnCMP_CMD, 0x70090010, 0x924110552bd74e7f // 16
	, RDnCMP_CMD, 0x70090018, 0xc62d21cd7f83b3f9 // 17
	, RDnCMP_CMD, 0x70090020, 0x0609e8f9dc6348b0 // 18
	, RDnCMP_CMD, 0x70090028, 0xe718fdc8b191a85d // 19
	, WRITE__CMD, 0x70090040, 0x5555555555555555 // 20
	, WRITE__CMD, 0x70090048, 0x5555555555555555 // 21
	, WRITE__CMD, 0x70090050, 0x5555555555555555 // 22
	, WRITE__CMD, 0x70090030, 0x0000000000000002 // 23
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 24
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 25
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 26
	, RDnCMP_CMD, 0x70090008, 0x0000000000001c87 // 27
	, RDnCMP_CMD, 0x70090010, 0x800d9d1eb5ef85ca // 28
	, RDnCMP_CMD, 0x70090018, 0x7b25290c95bf1c92 // 29
	, RDnCMP_CMD, 0x70090020, 0x1c5c70ef948d4185 // 30
	, RDnCMP_CMD, 0x70090028, 0xbca1f30b29bf728b // 31
	, WRITE__CMD, 0x70090040, 0x0438d0375eadcfb7 // 32
	, WRITE__CMD, 0x70090048, 0x700525c3f513a58e // 33
	, WRITE__CMD, 0x70090050, 0xf7a47f85321afe70 // 34
	, WRITE__CMD, 0x70090030, 0x0000000000000003 // 35
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 36
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 37
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 38
	, RDnCMP_CMD, 0x70090008, 0x0000000000001e47 // 39
	, RDnCMP_CMD, 0x70090010, 0x892bdbbb7af3e010 // 40
	, RDnCMP_CMD, 0x70090018, 0xa5a12d6c60a14b27 // 41
	, RDnCMP_CMD, 0x70090020, 0x8e8299517171ef93 // 42
	, RDnCMP_CMD, 0x70090028, 0xfd4919bf8f2bbf09 // 43
	, WRITE__CMD, 0x70090040, 0xed933afdcd118d19 // 44
	, WRITE__CMD, 0x70090048, 0xa60b120054d2d4eb // 45
	, WRITE__CMD, 0x70090050, 0xb5778927d86ce52a // 46
	, WRITE__CMD, 0x70090030, 0x0000000000000004 // 47
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 48
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 49
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 50
	, RDnCMP_CMD, 0x70090008, 0x0000000000001f27 // 51
	, RDnCMP_CMD, 0x70090010, 0x8db8f8e99d7dd2fd // 52
	, RDnCMP_CMD, 0x70090018, 0xcae32f5c1a2e60fd // 53
	, RDnCMP_CMD, 0x70090020, 0x4f24522f037a44cc // 54
	, RDnCMP_CMD, 0x70090028, 0x67a8c0f038bd0ca0 // 55
	, WRITE__CMD, 0x70090040, 0x1082f511e4e9d9f4 // 56
	, WRITE__CMD, 0x70090048, 0x6f6eafeeff824aca // 57
	, WRITE__CMD, 0x70090050, 0xd28904d96063f12f // 58
	, WRITE__CMD, 0x70090030, 0x0000000000000005 // 59
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 60
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 61
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 62
	, RDnCMP_CMD, 0x70090008, 0x00000000000012d8 // 63
	, RDnCMP_CMD, 0x70090010, 0x8ff16940eebacb8b // 64
	, RDnCMP_CMD, 0x70090018, 0x7d422e442769f510 // 65
	, RDnCMP_CMD, 0x70090020, 0x6c6d2c90dc358c72 // 66
	, RDnCMP_CMD, 0x70090028, 0x44ed7c24112934ea // 67
	, WRITE__CMD, 0x70090040, 0xf939cb0bf6b74af6 // 68
	, WRITE__CMD, 0x70090048, 0x9cc4071425e9eb05 // 69
	, WRITE__CMD, 0x70090050, 0xe3d8302fd188c2dc // 70
	, WRITE__CMD, 0x70090030, 0x0000000000000006 // 71
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 72
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 73
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 74
	, RDnCMP_CMD, 0x70090008, 0x0000000000001968 // 75
	, RDnCMP_CMD, 0x70090010, 0x8ed5a19457594730 // 76
	, RDnCMP_CMD, 0x70090018, 0x2692aec839ca3fe6 // 77
	, RDnCMP_CMD, 0x70090020, 0xa2e5fd99d1331366 // 78
	, RDnCMP_CMD, 0x70090028, 0xc1df3c01c7ddb9fd // 79
	, WRITE__CMD, 0x70090040, 0xd1edd6209fece6cf // 80
	, WRITE__CMD, 0x70090048, 0x7612f5d8e626a6cb // 81
	, WRITE__CMD, 0x70090050, 0xdbbd92e7d92597bf // 82
	, WRITE__CMD, 0x70090030, 0x0000000000000007 // 83
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 84
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 85
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 86
	, RDnCMP_CMD, 0x70090008, 0x00000000000012cf // 87
	, RDnCMP_CMD, 0x70090010, 0x8e47c5fe0ba8816d // 88
	, RDnCMP_CMD, 0x70090018, 0x8b7aee8e369bda9d // 89
	, RDnCMP_CMD, 0x70090020, 0x672bc1e67da9f270 // 90
	, RDnCMP_CMD, 0x70090028, 0xd0c1af7df21d23c4 // 91
	, WRITE__CMD, 0x70090040, 0x844e7c10844c4b20 // 92
	, WRITE__CMD, 0x70090048, 0xce4573f7f9a1d901 // 93
	, WRITE__CMD, 0x70090050, 0x50c1b6fc581f3f01 // 94
	, WRITE__CMD, 0x70090030, 0x0000000000000008 // 95
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 96
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 97
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 98
	, RDnCMP_CMD, 0x70090008, 0x0000000000001963 // 99
	, RDnCMP_CMD, 0x70090010, 0x8e0ef7cb25d06243 // 100
	, RDnCMP_CMD, 0x70090018, 0x5d8ecead31332820 // 101
	, RDnCMP_CMD, 0x70090020, 0xae76fa842314cc30 // 102
	, RDnCMP_CMD, 0x70090028, 0x13c35dab83b82a06 // 103
	, WRITE__CMD, 0x70090040, 0xeebfacd2ac23a42c // 104
	, WRITE__CMD, 0x70090048, 0x56e7141b6ef1c21b // 105
	, WRITE__CMD, 0x70090050, 0xd73564cc9213b6e4 // 106
	, WRITE__CMD, 0x70090030, 0x0000000000000009 // 107
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 108
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 109
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 110
	, RDnCMP_CMD, 0x70090008, 0x0000000000001cb5 // 111
	, RDnCMP_CMD, 0x70090010, 0x8e2a6ed1b2ec13d4 // 112
	, RDnCMP_CMD, 0x70090018, 0x36f4debcb2e7517e // 113
	, RDnCMP_CMD, 0x70090020, 0x9496e822c0fe1052 // 114
	, RDnCMP_CMD, 0x70090028, 0xefa3ee443a6b48eb // 115
	, WRITE__CMD, 0x70090040, 0x81190ef37d50cdc0 // 116
	, WRITE__CMD, 0x70090048, 0x39cdfd1a190fae17 // 117
	, WRITE__CMD, 0x70090050, 0x5856832e2c88f80f // 118
	, WRITE__CMD, 0x70090030, 0x000000000000000a // 119
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 120
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 121
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 122
	, RDnCMP_CMD, 0x70090008, 0x0000000000001a25 // 123
	, RDnCMP_CMD, 0x70090010, 0x8e38225cf9722b1f // 124
	, RDnCMP_CMD, 0x70090018, 0x8349d6b4730d6dd1 // 125
	, RDnCMP_CMD, 0x70090020, 0xec121492790b7073 // 126
	, RDnCMP_CMD, 0x70090028, 0xa28454bace2c3d0e // 127
	, WRITE__CMD, 0x70090040, 0x9a0ffb30ad7fe5dc // 128
	, WRITE__CMD, 0x70090048, 0x6c92270f2699d427 // 129
	, WRITE__CMD, 0x70090050, 0x66176c019264c2cd // 130
	, WRITE__CMD, 0x70090030, 0x000000000000000b // 131
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 132
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 133
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 134
	, RDnCMP_CMD, 0x70090008, 0x0000000000001d16 // 135
	, RDnCMP_CMD, 0x70090010, 0x8e31041a5cbd377a // 136
	, RDnCMP_CMD, 0x70090018, 0x599752b013f87386 // 137
	, RDnCMP_CMD, 0x70090020, 0x8310fb5d2009ffb9 // 138
	, RDnCMP_CMD, 0x70090028, 0xe9180aaffd3fe69d // 139
	, WRITE__CMD, 0x70090040, 0xd2fb80dfee1a2d33 // 140
	, WRITE__CMD, 0x70090048, 0xd5862bd755e986c9 // 141
	, WRITE__CMD, 0x70090050, 0xbcdae8c66953e63d // 142
	, WRITE__CMD, 0x70090030, 0x000000000000000c // 143
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 144
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 145
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 146
	, RDnCMP_CMD, 0x70090008, 0x0000000000001f43 // 147
	, RDnCMP_CMD, 0x70090010, 0x8e3597390e5ab948 // 148
	, RDnCMP_CMD, 0x70090018, 0xb4f810b22382fcad // 149
	, RDnCMP_CMD, 0x70090020, 0xa725af73cef60df2 // 150
	, RDnCMP_CMD, 0x70090028, 0x9ede41b73a65a0d9 // 151
	, WRITE__CMD, 0x70090040, 0xb901bcded5097b1d // 152
	, WRITE__CMD, 0x70090048, 0xe87d25f4a10b9a0a // 153
	, WRITE__CMD, 0x70090050, 0x0c33c92da6ff12f6 // 154
	, WRITE__CMD, 0x70090030, 0x000000000000000d // 155
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 156
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 157
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 158
	, RDnCMP_CMD, 0x70090008, 0x0000000000001fa5 // 159
	, RDnCMP_CMD, 0x70090010, 0x8e37dea8a7297e51 // 160
	, RDnCMP_CMD, 0x70090018, 0xc24fb1b33bbfbb38 // 161
	, RDnCMP_CMD, 0x70090020, 0xa77526b0eef17f57 // 162
	, RDnCMP_CMD, 0x70090028, 0x9ce4c7f5c3ba617c // 163
	, WRITE__CMD, 0x70090040, 0x9745730e2241b1da // 164
	, WRITE__CMD, 0x70090048, 0x888b0af6cc2a8ecf // 165
	, WRITE__CMD, 0x70090050, 0x16d909f988c91ef9 // 166
	, WRITE__CMD, 0x70090030, 0x000000000000000e // 167
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 168
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 169
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 170
	, RDnCMP_CMD, 0x70090008, 0x0000000000001fd6 // 171
	, RDnCMP_CMD, 0x70090010, 0x8e36fa6073909ddd // 172
	, RDnCMP_CMD, 0x70090018, 0x79146133b7a118f2 // 173
	, RDnCMP_CMD, 0x70090020, 0x9430269efc19f667 // 174
	, RDnCMP_CMD, 0x70090028, 0x760d64e8e274198e // 175
	, WRITE__CMD, 0x70090040, 0xc99b3dce79c00314 // 176
	, WRITE__CMD, 0x70090048, 0x92e5a31091f556c9 // 177
	, WRITE__CMD, 0x70090050, 0xf9bf1bf58b70adec // 178
	, WRITE__CMD, 0x70090030, 0x000000000000000f // 179
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 180
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 181
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 182
	, RDnCMP_CMD, 0x70090008, 0x0000000000001fef // 183
	, RDnCMP_CMD, 0x70090010, 0x8e36680419cc6c1b // 184
	, RDnCMP_CMD, 0x70090018, 0x24b98973f1ae4917 // 185
	, RDnCMP_CMD, 0x70090020, 0x029a01671cc9a34d // 186
	, RDnCMP_CMD, 0x70090028, 0x8b42c3c8f75c8a5c // 187
	, WRITE__CMD, 0x70090040, 0xcf3586daec43aec1 // 188
	, WRITE__CMD, 0x70090048, 0x864d6bcbe4d0100f // 189
	, WRITE__CMD, 0x70090050, 0x0d9efee4fa157e07 // 190
	, WRITE__CMD, 0x70090030, 0x0000000000000010 // 191
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 192
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 193
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 194
	, RDnCMP_CMD, 0x70090008, 0x0000000000001ff3 // 195
	, RDnCMP_CMD, 0x70090010, 0x8e3621362ce214f8 // 196
	, RDnCMP_CMD, 0x70090018, 0x0a6f7d53d2a9e1e5 // 197
	, RDnCMP_CMD, 0x70090020, 0x6141663a3507d8f6 // 198
	, RDnCMP_CMD, 0x70090028, 0x6e23844f992e1099 // 199
	, WRITE__CMD, 0x70090040, 0x87b236d3ef03dbc7 // 200
	, WRITE__CMD, 0x70090048, 0x4bcc6c1bcbc2ffd8 // 201
	, WRITE__CMD, 0x70090050, 0x70121d2b9234fa0f // 202
	, WRITE__CMD, 0x70090030, 0x0000000000000011 // 203
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 204
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 205
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 206
	, RDnCMP_CMD, 0x70090008, 0x0000000000001370 // 207
	, RDnCMP_CMD, 0x70090010, 0x8e3605af36752889 // 208
	, RDnCMP_CMD, 0x70090018, 0x9d040743c32a359c // 209
	, RDnCMP_CMD, 0x70090020, 0x2f0f7dcce1341614 // 210
	, RDnCMP_CMD, 0x70090028, 0xb0d90f238aaf6285 // 211
	, WRITE__CMD, 0x70090040, 0x141018f22fff7108 // 212
	, WRITE__CMD, 0x70090048, 0x31844610d853aa01 // 213
	, WRITE__CMD, 0x70090050, 0x9be0e92475e9c800 // 214
	, WRITE__CMD, 0x70090030, 0x0000000000000012 // 215
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 216
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 217
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 218
	, RDnCMP_CMD, 0x70090008, 0x00000000000019bc // 219
	, RDnCMP_CMD, 0x70090010, 0x8e3617e3bb3eb6b1 // 220
	, RDnCMP_CMD, 0x70090018, 0x56b1ba4bcbebdfa0 // 221
	, RDnCMP_CMD, 0x70090020, 0x4d626974f6a1ccda // 222
	, RDnCMP_CMD, 0x70090028, 0x30d3ad37841ef7d4 // 223
	, WRITE__CMD, 0x70090040, 0x252e28d50d1c8734 // 224
	, WRITE__CMD, 0x70090048, 0x23ed4431a1dbd8c4 // 225
	, WRITE__CMD, 0x70090050, 0x4bfc9ed7e92e48d4 // 226
	, WRITE__CMD, 0x70090030, 0x0000000000000013 // 227
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 228
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 229
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 230
	, RDnCMP_CMD, 0x70090008, 0x0000000000001cda // 231
	, RDnCMP_CMD, 0x70090010, 0x8e361ec5fd9b79ad // 232
	, RDnCMP_CMD, 0x70090018, 0x336b64cfcf8b2abe // 233
	, RDnCMP_CMD, 0x70090020, 0x3671d07dc01358c1 // 234
	, RDnCMP_CMD, 0x70090028, 0x444cd4b71e54c54d // 235
	, WRITE__CMD, 0x70090040, 0x222abd20b819ced5 // 236
	, WRITE__CMD, 0x70090048, 0x1fa835eab7f5a1dc // 237
	, WRITE__CMD, 0x70090050, 0x9fd91cd0c5752011 // 238
	, WRITE__CMD, 0x70090030, 0x0000000000000014 // 239
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 240
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 241
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 242
	, RDnCMP_CMD, 0x70090008, 0x0000000000001e69 // 243
	, RDnCMP_CMD, 0x70090010, 0x8e361a56dec99e23 // 244
	, RDnCMP_CMD, 0x70090018, 0x01860b8dcdbb5031 // 245
	, RDnCMP_CMD, 0x70090020, 0xd64fb3bc97e5710b // 246
	, RDnCMP_CMD, 0x70090028, 0x9260b8b3ac516a0e // 247
	, WRITE__CMD, 0x70090040, 0x7766d80dc8d57dc8 // 248
	, WRITE__CMD, 0x70090048, 0x38891bfaa5e11f4b // 249
	, WRITE__CMD, 0x70090050, 0xd066257d1bb2f080 // 250
	, WRITE__CMD, 0x70090030, 0x0000000000000015 // 251
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 252
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 253
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 254
	, RDnCMP_CMD, 0x70090008, 0x0000000000001f30 // 255
	, RDnCMP_CMD, 0x70090010, 0x8e36181f4f60ede4 // 256
	, RDnCMP_CMD, 0x70090018, 0x18f0bc2ccca36d76 // 257
	, RDnCMP_CMD, 0x70090020, 0x6b8cac37640cde1e // 258
	, RDnCMP_CMD, 0x70090028, 0x0124cdb42f1e9f34 // 259
	, WRITE__CMD, 0x70090040, 0xc50512ba87e67fcd // 260
	, WRITE__CMD, 0x70090048, 0x8407efd8af513cd8 // 261
	, WRITE__CMD, 0x70090050, 0xac52e0366a373705 // 262
	, WRITE__CMD, 0x70090030, 0x0000000000000016 // 263
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 264
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 265
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 266
	, RDnCMP_CMD, 0x70090008, 0x0000000000001f9c // 267
	, RDnCMP_CMD, 0x70090010, 0x8e36193b87b45407 // 268
	, RDnCMP_CMD, 0x70090018, 0x944be7fc4c2f73d5 // 269
	, RDnCMP_CMD, 0x70090020, 0x6064d37995ad4a39 // 270
	, RDnCMP_CMD, 0x70090028, 0xad8ba2632c0b8134 // 271
	, WRITE__CMD, 0x70090040, 0x52b7b11ffe3518d8 // 272
	, WRITE__CMD, 0x70090048, 0x98de5e1e258ca8c3 // 273
	, WRITE__CMD, 0x70090050, 0x468443331eff0cd9 // 274
	, WRITE__CMD, 0x70090030, 0x0000000000000017 // 275
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 276
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 277
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 278
	, RDnCMP_CMD, 0x70090008, 0x000000000000119e // 279
	, RDnCMP_CMD, 0x70090010, 0x8e3619a9e3de08f6 // 280
	, RDnCMP_CMD, 0x70090018, 0x52164a140c697c84 // 281
	, RDnCMP_CMD, 0x70090020, 0xa91b72f7bf720bbd // 282
	, RDnCMP_CMD, 0x70090028, 0x0e10d14b838051e9 // 283
	, WRITE__CMD, 0x70090040, 0xf6ca701add9640bb // 284
	, WRITE__CMD, 0x70090048, 0xac9410291201a4be // 285
	, WRITE__CMD, 0x70090050, 0x45d9970f038993da // 286
	, WRITE__CMD, 0x70090030, 0x0000000000000018 // 287
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 288
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 289
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 290
	, RDnCMP_CMD, 0x70090008, 0x0000000000001e34 // 291
	, RDnCMP_CMD, 0x70090010, 0x8e3619e0d1eb268e // 292
	, RDnCMP_CMD, 0x70090018, 0xb1389ce02c4a7b2c // 293
	, RDnCMP_CMD, 0x70090020, 0x65c6d7c3b607d0c8 // 294
	, RDnCMP_CMD, 0x70090028, 0x0aac0778fe5e99ae // 295
	, WRITE__CMD, 0x70090040, 0x7e8f5eda72e0640d // 296
	, WRITE__CMD, 0x70090048, 0xe8935f31d3af34e6 // 297
	, WRITE__CMD, 0x70090050, 0x5d6dbfe9abaa70c7 // 298
	, WRITE__CMD, 0x70090030, 0x0000000000000019 // 299
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 300
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 301
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 302
	, RDnCMP_CMD, 0x70090008, 0x0000000000001f1e // 303
	, RDnCMP_CMD, 0x70090010, 0x8e3619c448f1b1b2 // 304
	, RDnCMP_CMD, 0x70090018, 0xc0aff79a3c5bf8f8 // 305
	, RDnCMP_CMD, 0x70090020, 0xc60c0e6b0ea15fa1 // 306
	, RDnCMP_CMD, 0x70090028, 0xfd44b841f88260e8 // 307
	, WRITE__CMD, 0x70090040, 0xbbcdb5e0dc79d529 // 308
	, WRITE__CMD, 0x70090048, 0x0448efc4b93bbedb // 309
	, WRITE__CMD, 0x70090050, 0x6d6b5114519491c5 // 310
	, WRITE__CMD, 0x70090030, 0x000000000000001a // 311
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 312
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 313
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 314
	, RDnCMP_CMD, 0x70090008, 0x0000000000001f8b // 315
	, RDnCMP_CMD, 0x70090010, 0x8e3619d6047cfa2c // 316
	, RDnCMP_CMD, 0x70090018, 0xf864422734533912 // 317
	, RDnCMP_CMD, 0x70090020, 0x63412f59f16b18ef // 318
	, RDnCMP_CMD, 0x70090028, 0xf4e6ed12dd8a879f // 319
	, WRITE__CMD, 0x70090040, 0x5bbf8e298c5d762c // 320
	, WRITE__CMD, 0x70090048, 0x33bb03e4c244c13c // 321
	, WRITE__CMD, 0x70090050, 0x5da2a6ffef6583ce // 322
	, WRITE__CMD, 0x70090030, 0x000000000000001b // 323
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 324
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 325
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 326
	, RDnCMP_CMD, 0x70090008, 0x0000000000001fc1 // 327
	, RDnCMP_CMD, 0x70090010, 0x8e3619df223a5fe3 // 328
	, RDnCMP_CMD, 0x70090018, 0xe40198f9b05759e7 // 329
	, RDnCMP_CMD, 0x70090020, 0x49301dae963e921c // 330
	, RDnCMP_CMD, 0x70090028, 0xf534fb8d9c219c00 // 331
	, WRITE__CMD, 0x70090040, 0x523485f7cfcd0637 // 332
	, WRITE__CMD, 0x70090048, 0x30b423ddf51b77e0 // 333
	, WRITE__CMD, 0x70090050, 0xe6c342fc77b85a12 // 334
	, WRITE__CMD, 0x70090030, 0x000000000000001c // 335
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 336
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 337
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 338
	, RDnCMP_CMD, 0x70090008, 0x0000000000001fe4 // 339
	, RDnCMP_CMD, 0x70090010, 0x8e3619dbb1190d04 // 340
	, RDnCMP_CMD, 0x70090018, 0x6a337596f255699d // 341
	, RDnCMP_CMD, 0x70090020, 0x7403295a5696acb8 // 342
	, RDnCMP_CMD, 0x70090028, 0xd56d714e0a145342 // 343
	, WRITE__CMD, 0x70090040, 0x96117d3a72b9f925 // 344
	, WRITE__CMD, 0x70090048, 0x1fefe0bb775a72c3 // 345
	, WRITE__CMD, 0x70090050, 0xc5fb81c8cb65b216 // 346
	, WRITE__CMD, 0x70090030, 0x000000000000001d // 347
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 348
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 349
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 350
	, RDnCMP_CMD, 0x70090008, 0x00000000000012bc // 351
	, RDnCMP_CMD, 0x70090010, 0x8e3619d9f888a477 // 352
	, RDnCMP_CMD, 0x70090018, 0xad2a0321535471a0 // 353
	, RDnCMP_CMD, 0x70090020, 0x7b54b0ace73203a7 // 354
	, RDnCMP_CMD, 0x70090028, 0x109522df6d0ca387 // 355
	, WRITE__CMD, 0x70090040, 0x12295228f3cc40fd // 356
	, WRITE__CMD, 0x70090048, 0x3054e72e67f43d36 // 357
	, WRITE__CMD, 0x70090050, 0xf0e149edffc163ef // 358
	, WRITE__CMD, 0x70090030, 0x000000000000001e // 359
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 360
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 361
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 362
	, RDnCMP_CMD, 0x70090008, 0x000000000000195a // 363
	, RDnCMP_CMD, 0x70090010, 0x8e3619d8dc4070ce // 364
	, RDnCMP_CMD, 0x70090018, 0x4ea6b87a83d4fdbe // 365
	, RDnCMP_CMD, 0x70090020, 0x7c8293dd04576732 // 366
	, RDnCMP_CMD, 0x70090028, 0x3c5e8596a1be8827 // 367
	, WRITE__CMD, 0x70090040, 0x5894cb25551ddbbe // 368
	, WRITE__CMD, 0x70090048, 0x03d72127d2f0ffd6 // 369
	, WRITE__CMD, 0x70090050, 0x67e9032f4bb2c9c3 // 370
	, WRITE__CMD, 0x70090030, 0x000000000000001f // 371
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 372
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 373
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 374
	, RDnCMP_CMD, 0x70090008, 0x0000000000001ca9 // 375
	, RDnCMP_CMD, 0x70090010, 0x8e3619d84e241a92 // 376
	, RDnCMP_CMD, 0x70090018, 0xbf60e5d76b94bbb1 // 377
	, RDnCMP_CMD, 0x70090020, 0x05c24ee77e76f573 // 378
	, RDnCMP_CMD, 0x70090028, 0xf559f60cc46a9958 // 379
	, WRITE__CMD, 0x70090040, 0x4368d6e370b087da // 380
	, WRITE__CMD, 0x70090048, 0xddff8fd8da6688d9 // 381
	, WRITE__CMD, 0x70090050, 0x9bbbebcf41c1a5e3 // 382
	, WRITE__CMD, 0x70090030, 0x0000000000000020 // 383
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 384
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 385
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 386
	, RDnCMP_CMD, 0x70090008, 0x0000000000001e50 // 387
	, RDnCMP_CMD, 0x70090010, 0x8e3619d807162fbc // 388
	, RDnCMP_CMD, 0x70090018, 0xc783cb019fb498b6 // 389
	, RDnCMP_CMD, 0x70090020, 0x80ba92442a023b36 // 390
	, RDnCMP_CMD, 0x70090028, 0xe8f674d9e41c175b // 391
	, WRITE__CMD, 0x70090040, 0x04bf1221743cf2de // 392
	, WRITE__CMD, 0x70090048, 0x9a2ce70e79801539 // 393
	, WRITE__CMD, 0x70090050, 0x2e5c8ece5b65690e // 394
	, WRITE__CMD, 0x70090030, 0x0000000000000021 // 395
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 396
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 397
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 398
	, RDnCMP_CMD, 0x70090008, 0x0000000000001f2c // 399
	, RDnCMP_CMD, 0x70090010, 0x8e3619d8238f352b // 400
	, RDnCMP_CMD, 0x70090018, 0xfbf25c6ae5a48935 // 401
	, RDnCMP_CMD, 0x70090020, 0x6617fee7e61b2fb7 // 402
	, RDnCMP_CMD, 0x70090028, 0x83d17844ad9963f0 // 403
	, WRITE__CMD, 0x70090040, 0x955b25c507a65130 // 404
	, WRITE__CMD, 0x70090048, 0x9691bb14d401e3f4 // 405
	, WRITE__CMD, 0x70090050, 0x8c0d5821d2fa54eb // 406
	, WRITE__CMD, 0x70090030, 0x0000000000000022 // 407
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 408
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 409
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 410
	, RDnCMP_CMD, 0x70090008, 0x0000000000001e5b // 411
	, RDnCMP_CMD, 0x70090010, 0x8e3619d831c3b860 // 412
	, RDnCMP_CMD, 0x70090018, 0x65ca97df58ac81f4 // 413
	, RDnCMP_CMD, 0x70090020, 0x4f3d869e804bf394 // 414
	, RDnCMP_CMD, 0x70090028, 0xc7402a7354e1712f // 415
	, WRITE__CMD, 0x70090040, 0xa988a71a2a02240d // 416
	, WRITE__CMD, 0x70090048, 0x5189e6e93078d015 // 417
	, WRITE__CMD, 0x70090050, 0x72ebe8e82a8335c8 // 418
	, WRITE__CMD, 0x70090030, 0x0000000000000023 // 419
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 420
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 421
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 422
	, RDnCMP_CMD, 0x70090008, 0x00000000000012e1 // 423
	, RDnCMP_CMD, 0x70090010, 0x8e3619d838e5fec5 // 424
	, RDnCMP_CMD, 0x70090018, 0xaad6f20586288594 // 425
	, RDnCMP_CMD, 0x70090020, 0x686ee41fc9118e19 // 426
	, RDnCMP_CMD, 0x70090028, 0x8b2e225c16b563dc // 427
	, WRITE__CMD, 0x70090040, 0xd8d33e0a3f6dddfd // 428
	, WRITE__CMD, 0x70090048, 0x8baf1c0cfc9c22f6 // 429
	, WRITE__CMD, 0x70090050, 0xbb1ad1096ab9a12c // 430
	, WRITE__CMD, 0x70090030, 0x0000000000000024 // 431
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 432
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 433
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 434
	, RDnCMP_CMD, 0x70090008, 0x0000000000001974 // 435
	, RDnCMP_CMD, 0x70090010, 0x8e3619d83c76dd97 // 436
	, RDnCMP_CMD, 0x70090018, 0x4d58c0e8e96a87a4 // 437
	, RDnCMP_CMD, 0x70090020, 0x98e7c1d0a16fbe8d // 438
	, RDnCMP_CMD, 0x70090028, 0x3a962d951de6fcc7 // 439
	, WRITE__CMD, 0x70090040, 0x988040e500b6a90e // 440
	, WRITE__CMD, 0x70090048, 0x1928a7f3461804fd // 441
	, WRITE__CMD, 0x70090050, 0x345b4ff8377f801c // 442
	, WRITE__CMD, 0x70090030, 0x0000000000000025 // 443
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 444
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 445
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 446
	, RDnCMP_CMD, 0x70090008, 0x0000000000001e5b // 447
	, RDnCMP_CMD, 0x70090010, 0x8e3619d83e3f4c3e // 448
	, RDnCMP_CMD, 0x70090018, 0x3e9fd99e5ecb86bc // 449
	, RDnCMP_CMD, 0x70090020, 0xa594a746f482c035 // 450
	, RDnCMP_CMD, 0x70090028, 0xbb032c30d6ebbd0e // 451
	, WRITE__CMD, 0x70090040, 0x48acbefcec7f39d6 // 452
	, WRITE__CMD, 0x70090048, 0xc9ef410585fd1efd // 453
	, WRITE__CMD, 0x70090050, 0x8dadafc74d93c72f // 454
	, WRITE__CMD, 0x70090030, 0x0000000000000001 // 455
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 456
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 457
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 458
	, RDnCMP_CMD, 0x70090008, 0x0000000000001907 // 459
	, RDnCMP_CMD, 0x70090010, 0x924110552bd74e7f // 460
	, RDnCMP_CMD, 0x70090018, 0xc62d21cd7f83b3f9 // 461
	, RDnCMP_CMD, 0x70090020, 0xe0d58f55bcf4a990 // 462
	, RDnCMP_CMD, 0x70090028, 0xac9248eeaaee2b80 // 463
	, WRITE__CMD, 0x70090030, 0x0000000000000000 // 464
	, WRITE__CMD, 0x70090040, 0x92296d13abf5b325 // 465
	, WRITE__CMD, 0x70090048, 0x8f6e22d91ff59e34 // 466
	, WRITE__CMD, 0x70090050, 0x556600c2a6a291ca // 467
	, WRITE__CMD, 0x70090060, 0x00005c22fee52078 // 468
	, WRITE__CMD, 0x70090058, 0x000000002aaab0a3 // 469
	, WRITE__CMD, 0x70090030, 0x0000000000000001 // 470
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 471
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 472
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 473
	, RDnCMP_CMD, 0x70090008, 0x0000000000001907 // 474
	, RDnCMP_CMD, 0x70090010, 0x5b01abdf2d263f34 // 475
	, RDnCMP_CMD, 0x70090018, 0x908af5d6c06af7cb // 476
	, RDnCMP_CMD, 0x70090020, 0x9f3ef2ba3e641deb // 477
	, RDnCMP_CMD, 0x70090028, 0xa21a57dfe0931452 // 478
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 479
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 480
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 481
	, RDnCMP_CMD, 0x70090008, 0x0000000000000527 // 482
	, RDnCMP_CMD, 0x70090010, 0x498fcd2422bd75b0 // 483
	, RDnCMP_CMD, 0x70090018, 0x1abc641906411d0c // 484
	, RDnCMP_CMD, 0x70090020, 0x969bca322eefecae // 485
	, RDnCMP_CMD, 0x70090028, 0x399d97855b189499 // 486
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 487
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 488
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 489
	, RDnCMP_CMD, 0x70090008, 0x0000000000001289 // 490
	, RDnCMP_CMD, 0x70090010, 0xa6db4d9f3de26e10 // 491
	, RDnCMP_CMD, 0x70090018, 0xc192b5c5c52b67cf // 492
	, RDnCMP_CMD, 0x70090020, 0x4e8d6091b81df044 // 493
	, RDnCMP_CMD, 0x70090028, 0x11da77f899924fe4 // 494
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 495
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 496
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 497
	, RDnCMP_CMD, 0x70090008, 0x0000000000001ead // 498
	, RDnCMP_CMD, 0x70090010, 0x789b843064ad7170 // 499
	, RDnCMP_CMD, 0x70090018, 0x803c81679ddc92d6 // 500
	, RDnCMP_CMD, 0x70090020, 0x8d20f7fe79430923 // 501
	, RDnCMP_CMD, 0x70090028, 0x0400f3975d57618e // 502
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 503
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 504
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 505
	, RDnCMP_CMD, 0x70090008, 0x000000000000022a // 506
	, RDnCMP_CMD, 0x70090010, 0x4faf558a4d150984 // 507
	, RDnCMP_CMD, 0x70090018, 0x023114894462010c // 508
	, RDnCMP_CMD, 0x70090020, 0x18e51dca9ea5b657 // 509
	, RDnCMP_CMD, 0x70090028, 0x57824f8d15e0cb7e // 510
	, WRITE__CMD, 0x70090000, 0x0000000000000001 // 511
	, WRITE__CMD, 0x70090000, 0x0000000000000000 // 512
	, RDSPIN_CMD, 0x70090000, 0x0000000000000002, 0x2, 0x1f4 // 513
	, RDnCMP_CMD, 0x70090008, 0x0000000000001647 // 514
	, RDnCMP_CMD, 0x70090010, 0x854261008c44e8b4 // 515
	, RDnCMP_CMD, 0x70090018, 0x6a215b01abdf2d26 // 516
	, RDnCMP_CMD, 0x70090020, 0x86f8b9fc96f7c1ca // 517
	, RDnCMP_CMD, 0x70090028, 0x9f2fd6de9f09fb2e // 518
};

#define GPS_0_adrBase 0x0070090000
#define GPS_0_adrSize 0x10000
#define GPS_0_cmdCnt4Single 19
#define GPS_0_totalCommands 518
#endif
