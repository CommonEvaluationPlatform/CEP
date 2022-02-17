//************************************************************************
// Copyright 2022 Massachusetts Institute of Technology
//
// This file is auto-generated for test: GPS_REDACT. Do not modify!!!
//
// Generated on: Feb 16 2022 14:44:30
//************************************************************************
#ifndef GPS_REDACT_playback_H
#define GPS_REDACT_playback_H

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

// GPS_REDACT command sequences to playback
uint64_t GPS_REDACT_playback[] = { 
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
	, WRITE__CMD, 0x70091040, 0xaaaaaaaaaaaaaaaa // 20
	, WRITE__CMD, 0x70091048, 0xaaaaaaaaaaaaaaaa // 21
	, WRITE__CMD, 0x70091050, 0xaaaaaaaaaaaaaaaa // 22
	, WRITE__CMD, 0x70091030, 0x0000000000000001 // 23
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 24
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 25
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 26
	, RDnCMP_CMD, 0x70091008, 0x0000000000000527 // 27
	, RDnCMP_CMD, 0x70091010, 0xa4cc77e4c4a5df08 // 28
	, RDnCMP_CMD, 0x70091018, 0x1e90b013d5d49f81 // 29
	, RDnCMP_CMD, 0x70091020, 0xe0ac4307eefef3ea // 30
	, RDnCMP_CMD, 0x70091028, 0x1b8bef47549c2231 // 31
	, WRITE__CMD, 0x70091040, 0x5555555555555555 // 32
	, WRITE__CMD, 0x70091048, 0x5555555555555555 // 33
	, WRITE__CMD, 0x70091050, 0x5555555555555555 // 34
	, WRITE__CMD, 0x70091030, 0x0000000000000002 // 35
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 36
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 37
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 38
	, RDnCMP_CMD, 0x70091008, 0x0000000000001c87 // 39
	, RDnCMP_CMD, 0x70091010, 0x800d9d1eb5ef85ca // 40
	, RDnCMP_CMD, 0x70091018, 0x7b25290c95bf1c92 // 41
	, RDnCMP_CMD, 0x70091020, 0x1c5c70ef948d4185 // 42
	, RDnCMP_CMD, 0x70091028, 0xbca1f30b29bf728b // 43
	, WRITE__CMD, 0x70091040, 0xd53665fe882b2b90 // 44
	, WRITE__CMD, 0x70091048, 0x801ce7ce38c7ff28 // 45
	, WRITE__CMD, 0x70091050, 0xa765ced9b4787d5e // 46
	, WRITE__CMD, 0x70091030, 0x0000000000000003 // 47
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 48
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 49
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 50
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e47 // 51
	, RDnCMP_CMD, 0x70091010, 0x892bdbbb7af3e010 // 52
	, RDnCMP_CMD, 0x70091018, 0xa5a12d6c60a14b27 // 53
	, RDnCMP_CMD, 0x70091020, 0xb9d25d0e5607d85e // 54
	, RDnCMP_CMD, 0x70091028, 0x3d2e5338a5e3686d // 55
	, WRITE__CMD, 0x70091040, 0x426cfbf1b74424f0 // 56
	, WRITE__CMD, 0x70091048, 0x5c17ebe76ae1abd2 // 57
	, WRITE__CMD, 0x70091050, 0xefe7be08e2872936 // 58
	, WRITE__CMD, 0x70091030, 0x0000000000000004 // 59
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 60
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 61
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 62
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f27 // 63
	, RDnCMP_CMD, 0x70091010, 0x8db8f8e99d7dd2fd // 64
	, RDnCMP_CMD, 0x70091018, 0xcae32f5c1a2e60fd // 65
	, RDnCMP_CMD, 0x70091020, 0xf3345d788711657c // 66
	, RDnCMP_CMD, 0x70091028, 0x4ac59a83ae97733e // 67
	, WRITE__CMD, 0x70091040, 0xfd040fedebe13f14 // 68
	, WRITE__CMD, 0x70091048, 0x994ccada265773e8 // 69
	, WRITE__CMD, 0x70091050, 0x08dc9f2d2d741403 // 70
	, WRITE__CMD, 0x70091030, 0x0000000000000005 // 71
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 72
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 73
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 74
	, RDnCMP_CMD, 0x70091008, 0x00000000000012d8 // 75
	, RDnCMP_CMD, 0x70091010, 0x8ff16940eebacb8b // 76
	, RDnCMP_CMD, 0x70091018, 0x7d422e442769f510 // 77
	, RDnCMP_CMD, 0x70091020, 0x2f23a8c0e44fd049 // 78
	, RDnCMP_CMD, 0x70091028, 0x526139b0aa884546 // 79
	, WRITE__CMD, 0x70091040, 0x1ca81803b3e46cf7 // 80
	, WRITE__CMD, 0x70091048, 0xdb8ff9ce9c4f3e04 // 81
	, WRITE__CMD, 0x70091050, 0xe47677c236e73cfd // 82
	, WRITE__CMD, 0x70091030, 0x0000000000000006 // 83
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 84
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 85
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 86
	, RDnCMP_CMD, 0x70091008, 0x0000000000001968 // 87
	, RDnCMP_CMD, 0x70091010, 0x8ed5a19457594730 // 88
	, RDnCMP_CMD, 0x70091018, 0x2692aec839ca3fe6 // 89
	, RDnCMP_CMD, 0x70091020, 0xf3348ffbf84471fb // 90
	, RDnCMP_CMD, 0x70091028, 0x6b5d046f50da22a1 // 91
	, WRITE__CMD, 0x70091040, 0xb693df2c44d58fe2 // 92
	, WRITE__CMD, 0x70091048, 0x1e4e28d0c7cc1301 // 93
	, WRITE__CMD, 0x70091050, 0x3ff1a3c5b818f0ec // 94
	, WRITE__CMD, 0x70091030, 0x0000000000000007 // 95
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 96
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 97
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 98
	, RDnCMP_CMD, 0x70091008, 0x00000000000012cf // 99
	, RDnCMP_CMD, 0x70091010, 0x8e47c5fe0ba8816d // 100
	, RDnCMP_CMD, 0x70091018, 0x8b7aee8e369bda9d // 101
	, RDnCMP_CMD, 0x70091020, 0x90a1529458c10a16 // 102
	, RDnCMP_CMD, 0x70091028, 0xfa243e53f68da811 // 103
	, WRITE__CMD, 0x70091040, 0x8ba345f6d0c832d6 // 104
	, WRITE__CMD, 0x70091048, 0x1b1709139f403ef0 // 105
	, WRITE__CMD, 0x70091050, 0x1a2e6d0bda510a31 // 106
	, WRITE__CMD, 0x70091030, 0x0000000000000008 // 107
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 108
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 109
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 110
	, RDnCMP_CMD, 0x70091008, 0x0000000000001963 // 111
	, RDnCMP_CMD, 0x70091010, 0x8e0ef7cb25d06243 // 112
	, RDnCMP_CMD, 0x70091018, 0x5d8ecead31332820 // 113
	, RDnCMP_CMD, 0x70091020, 0x4bff990cd59aa85b // 114
	, RDnCMP_CMD, 0x70091028, 0x797b320d1750953f // 115
	, WRITE__CMD, 0x70091040, 0x151ba5c8afa34ff5 // 116
	, WRITE__CMD, 0x70091048, 0x814be324e5879c27 // 117
	, WRITE__CMD, 0x70091050, 0xc4b76e35b24dffc8 // 118
	, WRITE__CMD, 0x70091030, 0x0000000000000009 // 119
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 120
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 121
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 122
	, RDnCMP_CMD, 0x70091008, 0x0000000000001cb5 // 123
	, RDnCMP_CMD, 0x70091010, 0x8e2a6ed1b2ec13d4 // 124
	, RDnCMP_CMD, 0x70091018, 0x36f4debcb2e7517e // 125
	, RDnCMP_CMD, 0x70091020, 0xd69f61dedbfa6cf2 // 126
	, RDnCMP_CMD, 0x70091028, 0xc6386dc2b465932a // 127
	, WRITE__CMD, 0x70091040, 0x8f0059ec6d9f5203 // 128
	, WRITE__CMD, 0x70091048, 0x47876d292f5ab934 // 129
	, WRITE__CMD, 0x70091050, 0x6b9af63257895932 // 130
	, WRITE__CMD, 0x70091030, 0x000000000000000a // 131
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 132
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 133
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 134
	, RDnCMP_CMD, 0x70091008, 0x0000000000001a25 // 135
	, RDnCMP_CMD, 0x70091010, 0x8e38225cf9722b1f // 136
	, RDnCMP_CMD, 0x70091018, 0x8349d6b4730d6dd1 // 137
	, RDnCMP_CMD, 0x70091020, 0xc7635c86a9234dfe // 138
	, RDnCMP_CMD, 0x70091028, 0x73ccb8d34c0c9885 // 139
	, WRITE__CMD, 0x70091040, 0x8813e63a3b880ffe // 140
	, WRITE__CMD, 0x70091048, 0x99d2eaf32a5606d4 // 141
	, WRITE__CMD, 0x70091050, 0x2d210338254f4f37 // 142
	, WRITE__CMD, 0x70091030, 0x000000000000000b // 143
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 144
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 145
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 146
	, RDnCMP_CMD, 0x70091008, 0x0000000000001d16 // 147
	, RDnCMP_CMD, 0x70091010, 0x8e31041a5cbd377a // 148
	, RDnCMP_CMD, 0x70091018, 0x599752b013f87386 // 149
	, RDnCMP_CMD, 0x70091020, 0x50506264353293c1 // 150
	, RDnCMP_CMD, 0x70091028, 0x46074a2e319fe6f6 // 151
	, WRITE__CMD, 0x70091040, 0x32ae5fce5225912c // 152
	, WRITE__CMD, 0x70091048, 0xf4baae1d85321807 // 153
	, WRITE__CMD, 0x70091050, 0x3e57d0dc4c78a4f9 // 154
	, WRITE__CMD, 0x70091030, 0x000000000000000c // 155
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 156
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 157
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 158
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f43 // 159
	, RDnCMP_CMD, 0x70091010, 0x8e3597390e5ab948 // 160
	, RDnCMP_CMD, 0x70091018, 0xb4f810b22382fcad // 161
	, RDnCMP_CMD, 0x70091020, 0x7cef8ea34389f85a // 162
	, RDnCMP_CMD, 0x70091028, 0x26eefbd0ab89e6d9 // 163
	, WRITE__CMD, 0x70091040, 0xdcdeb92304aaaf15 // 164
	, WRITE__CMD, 0x70091048, 0xae702dbf34c253ca // 165
	, WRITE__CMD, 0x70091050, 0x7ac4992875fc60bb // 166
	, WRITE__CMD, 0x70091030, 0x000000000000000d // 167
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 168
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 169
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 170
	, RDnCMP_CMD, 0x70091008, 0x0000000000001fa5 // 171
	, RDnCMP_CMD, 0x70091010, 0x8e37dea8a7297e51 // 172
	, RDnCMP_CMD, 0x70091018, 0xc24fb1b33bbfbb38 // 173
	, RDnCMP_CMD, 0x70091020, 0x2bb2a75437e979ba // 174
	, RDnCMP_CMD, 0x70091028, 0x724d84a051266bc6 // 175
	, WRITE__CMD, 0x70091040, 0x7b1af7fd3584acf5 // 176
	, WRITE__CMD, 0x70091048, 0xe41ea70df82d3cfc // 177
	, WRITE__CMD, 0x70091050, 0x7b3092388a247616 // 178
	, WRITE__CMD, 0x70091030, 0x000000000000000e // 179
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 180
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 181
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 182
	, RDnCMP_CMD, 0x70091008, 0x0000000000001fd6 // 183
	, RDnCMP_CMD, 0x70091010, 0x8e36fa6073909ddd // 184
	, RDnCMP_CMD, 0x70091018, 0x79146133b7a118f2 // 185
	, RDnCMP_CMD, 0x70091020, 0xc87587a31e5e69fd // 186
	, RDnCMP_CMD, 0x70091028, 0x89f77aa93ca07be3 // 187
	, WRITE__CMD, 0x70091040, 0x0b578cd329da82dc // 188
	, WRITE__CMD, 0x70091048, 0x1f2d80e6403bee03 // 189
	, WRITE__CMD, 0x70091050, 0x0a87c8c6ccda60ee // 190
	, WRITE__CMD, 0x70091030, 0x000000000000000f // 191
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 192
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 193
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 194
	, RDnCMP_CMD, 0x70091008, 0x0000000000001fef // 195
	, RDnCMP_CMD, 0x70091010, 0x8e36680419cc6c1b // 196
	, RDnCMP_CMD, 0x70091018, 0x24b98973f1ae4917 // 197
	, RDnCMP_CMD, 0x70091020, 0x90a525ba5a2dce26 // 198
	, RDnCMP_CMD, 0x70091028, 0x4065756b2ee4d7f0 // 199
	, WRITE__CMD, 0x70091040, 0x05034ce11097dfcc // 200
	, WRITE__CMD, 0x70091048, 0x1f3f07c5f1179902 // 201
	, WRITE__CMD, 0x70091050, 0xf2c74b020fd45c10 // 202
	, WRITE__CMD, 0x70091030, 0x0000000000000010 // 203
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 204
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 205
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 206
	, RDnCMP_CMD, 0x70091008, 0x0000000000001ff3 // 207
	, RDnCMP_CMD, 0x70091010, 0x8e3621362ce214f8 // 208
	, RDnCMP_CMD, 0x70091018, 0x0a6f7d53d2a9e1e5 // 209
	, RDnCMP_CMD, 0x70091020, 0x3d6e9cd1e6d32f59 // 210
	, RDnCMP_CMD, 0x70091028, 0x6e2292e4657ea0ff // 211
	, WRITE__CMD, 0x70091040, 0x49babefb020d8ad1 // 212
	, WRITE__CMD, 0x70091048, 0x2ce0dc0ef8063423 // 213
	, WRITE__CMD, 0x70091050, 0xe3a06000dbfb52cd // 214
	, WRITE__CMD, 0x70091030, 0x0000000000000011 // 215
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 216
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 217
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 218
	, RDnCMP_CMD, 0x70091008, 0x0000000000001370 // 219
	, RDnCMP_CMD, 0x70091010, 0x8e3605af36752889 // 220
	, RDnCMP_CMD, 0x70091018, 0x9d040743c32a359c // 221
	, RDnCMP_CMD, 0x70091020, 0x6ed81832905ca126 // 222
	, RDnCMP_CMD, 0x70091028, 0xfaea43228746a5e0 // 223
	, WRITE__CMD, 0x70091040, 0x14e0f808e350c6e8 // 224
	, WRITE__CMD, 0x70091048, 0x162960cb443615da // 225
	, WRITE__CMD, 0x70091050, 0xa070e50608dc11fa // 226
	, WRITE__CMD, 0x70091030, 0x0000000000000012 // 227
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 228
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 229
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 230
	, RDnCMP_CMD, 0x70091008, 0x00000000000019bc // 231
	, RDnCMP_CMD, 0x70091010, 0x8e3617e3bb3eb6b1 // 232
	, RDnCMP_CMD, 0x70091018, 0x56b1ba4bcbebdfa0 // 233
	, RDnCMP_CMD, 0x70091020, 0x8dd881b4e32c0ea9 // 234
	, RDnCMP_CMD, 0x70091028, 0xc948befb1814fbdc // 235
	, WRITE__CMD, 0x70091040, 0x0e1c32158b7bcac4 // 236
	, WRITE__CMD, 0x70091048, 0xec2707c18fa88235 // 237
	, WRITE__CMD, 0x70091050, 0x34e3f7f8307884be // 238
	, WRITE__CMD, 0x70091030, 0x0000000000000013 // 239
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 240
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 241
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 242
	, RDnCMP_CMD, 0x70091008, 0x0000000000001cda // 243
	, RDnCMP_CMD, 0x70091010, 0x8e361ec5fd9b79ad // 244
	, RDnCMP_CMD, 0x70091018, 0x336b64cfcf8b2abe // 245
	, RDnCMP_CMD, 0x70091020, 0xf5a8147b0bd6988d // 246
	, RDnCMP_CMD, 0x70091028, 0x853a568c49f27589 // 247
	, WRITE__CMD, 0x70091040, 0x0a35b1db992b22fc // 248
	, WRITE__CMD, 0x70091048, 0x44194d107f8dd1da // 249
	, WRITE__CMD, 0x70091050, 0xab7f29c0faee21f2 // 250
	, WRITE__CMD, 0x70091030, 0x0000000000000014 // 251
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 252
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 253
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 254
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e69 // 255
	, RDnCMP_CMD, 0x70091010, 0x8e361a56dec99e23 // 256
	, RDnCMP_CMD, 0x70091018, 0x01860b8dcdbb5031 // 257
	, RDnCMP_CMD, 0x70091020, 0x66ce34e1c865149e // 258
	, RDnCMP_CMD, 0x70091028, 0x7db4362f6d8e4017 // 259
	, WRITE__CMD, 0x70091040, 0x1b4cca364b1017cc // 260
	, WRITE__CMD, 0x70091048, 0xec490b12e81dcaff // 261
	, WRITE__CMD, 0x70091050, 0xc87c0ff135e67b28 // 262
	, WRITE__CMD, 0x70091030, 0x0000000000000015 // 263
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 264
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 265
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 266
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f30 // 267
	, RDnCMP_CMD, 0x70091010, 0x8e36181f4f60ede4 // 268
	, RDnCMP_CMD, 0x70091018, 0x18f0bc2ccca36d76 // 269
	, RDnCMP_CMD, 0x70091020, 0x3172f54ea709931a // 270
	, RDnCMP_CMD, 0x70091028, 0x98fffdce77818589 // 271
	, WRITE__CMD, 0x70091040, 0xacbef0d98202b32a // 272
	, WRITE__CMD, 0x70091048, 0x048608f1af1e6007 // 273
	, WRITE__CMD, 0x70091050, 0x1e1b6cd602597fcb // 274
	, WRITE__CMD, 0x70091030, 0x0000000000000016 // 275
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 276
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 277
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 278
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f9c // 279
	, RDnCMP_CMD, 0x70091010, 0x8e36193b87b45407 // 280
	, RDnCMP_CMD, 0x70091018, 0x944be7fc4c2f73d5 // 281
	, RDnCMP_CMD, 0x70091020, 0xac168b4b56fdc66c // 282
	, RDnCMP_CMD, 0x70091028, 0x12730166116205a5 // 283
	, WRITE__CMD, 0x70091040, 0xdd9911c2b74b05f6 // 284
	, WRITE__CMD, 0x70091048, 0x0509c2f14f09352b // 285
	, WRITE__CMD, 0x70091050, 0x46dfa8361ed97e2d // 286
	, WRITE__CMD, 0x70091030, 0x0000000000000017 // 287
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 288
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 289
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 290
	, RDnCMP_CMD, 0x70091008, 0x000000000000119e // 291
	, RDnCMP_CMD, 0x70091010, 0x8e3619a9e3de08f6 // 292
	, RDnCMP_CMD, 0x70091018, 0x52164a140c697c84 // 293
	, RDnCMP_CMD, 0x70091020, 0xac98cac4c1ed25eb // 294
	, RDnCMP_CMD, 0x70091028, 0x82dbee2ef1a1a735 // 295
	, WRITE__CMD, 0x70091040, 0xfe7637d3692690d8 // 296
	, WRITE__CMD, 0x70091048, 0x0ebfecf57a5abfdc // 297
	, WRITE__CMD, 0x70091050, 0xb75687f6c42e7a3a // 298
	, WRITE__CMD, 0x70091030, 0x0000000000000018 // 299
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 300
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 301
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 302
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e34 // 303
	, RDnCMP_CMD, 0x70091010, 0x8e3619e0d1eb268e // 304
	, RDnCMP_CMD, 0x70091018, 0xb1389ce02c4a7b2c // 305
	, RDnCMP_CMD, 0x70091020, 0x4dc11c903bb2a13e // 306
	, RDnCMP_CMD, 0x70091028, 0xc223f93f0ff8dd75 // 307
	, WRITE__CMD, 0x70091040, 0xe814dbccc02aedf2 // 308
	, WRITE__CMD, 0x70091048, 0x7d3612fff4a262fc // 309
	, WRITE__CMD, 0x70091050, 0x7899f60b2754a6e8 // 310
	, WRITE__CMD, 0x70091030, 0x0000000000000019 // 311
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 312
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 313
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 314
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f1e // 315
	, RDnCMP_CMD, 0x70091010, 0x8e3619c448f1b1b2 // 316
	, RDnCMP_CMD, 0x70091018, 0xc0aff79a3c5bf8f8 // 317
	, RDnCMP_CMD, 0x70091020, 0x9feb2479655470e2 // 318
	, RDnCMP_CMD, 0x70091028, 0x9bdb36c5e6517b47 // 319
	, WRITE__CMD, 0x70091040, 0xfd7bf9e8e7549cfb // 320
	, WRITE__CMD, 0x70091048, 0x1173dffbea2484eb // 321
	, WRITE__CMD, 0x70091050, 0x08c11e3b0f7322bd // 322
	, WRITE__CMD, 0x70091030, 0x000000000000001a // 323
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 324
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 325
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 326
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f8b // 327
	, RDnCMP_CMD, 0x70091010, 0x8e3619d6047cfa2c // 328
	, RDnCMP_CMD, 0x70091018, 0xf864422734533912 // 329
	, RDnCMP_CMD, 0x70091020, 0x7df467ae3f0594a5 // 330
	, RDnCMP_CMD, 0x70091028, 0xc98ff1402a47ba00 // 331
	, WRITE__CMD, 0x70091040, 0x680be817cf4a31e4 // 332
	, WRITE__CMD, 0x70091048, 0x2a0dabcbde4d6903 // 333
	, WRITE__CMD, 0x70091050, 0x88f433deaeaecbe7 // 334
	, WRITE__CMD, 0x70091030, 0x000000000000001b // 335
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 336
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 337
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 338
	, RDnCMP_CMD, 0x70091008, 0x0000000000001fc1 // 339
	, RDnCMP_CMD, 0x70091010, 0x8e3619df223a5fe3 // 340
	, RDnCMP_CMD, 0x70091018, 0xe40198f9b05759e7 // 341
	, RDnCMP_CMD, 0x70091020, 0x59992d7abef96c88 // 342
	, RDnCMP_CMD, 0x70091028, 0x3eb5e715ef100ac2 // 343
	, WRITE__CMD, 0x70091040, 0x9bb0d20a06f394e6 // 344
	, WRITE__CMD, 0x70091048, 0x686bded029825024 // 345
	, WRITE__CMD, 0x70091050, 0xe56ec109c994af21 // 346
	, WRITE__CMD, 0x70091030, 0x000000000000001c // 347
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 348
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 349
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 350
	, RDnCMP_CMD, 0x70091008, 0x0000000000001fe4 // 351
	, RDnCMP_CMD, 0x70091010, 0x8e3619dbb1190d04 // 352
	, RDnCMP_CMD, 0x70091018, 0x6a337596f255699d // 353
	, RDnCMP_CMD, 0x70091020, 0x09c1cd046e1429c7 // 354
	, RDnCMP_CMD, 0x70091028, 0x86cebd057bbeba22 // 355
	, WRITE__CMD, 0x70091040, 0x8d2df9cf831fd6ca // 356
	, WRITE__CMD, 0x70091048, 0x5be8f12d034bf6f1 // 357
	, WRITE__CMD, 0x70091050, 0x7e6edc2813e578d5 // 358
	, WRITE__CMD, 0x70091030, 0x000000000000001d // 359
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 360
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 361
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 362
	, RDnCMP_CMD, 0x70091008, 0x00000000000012bc // 363
	, RDnCMP_CMD, 0x70091010, 0x8e3619d9f888a477 // 364
	, RDnCMP_CMD, 0x70091018, 0xad2a0321535471a0 // 365
	, RDnCMP_CMD, 0x70091020, 0xa87da7177f17b608 // 366
	, RDnCMP_CMD, 0x70091028, 0x4e8cf744a3c0d8ab // 367
	, WRITE__CMD, 0x70091040, 0x442ad430693cc036 // 368
	, WRITE__CMD, 0x70091048, 0xce93f1e2c415afce // 369
	, WRITE__CMD, 0x70091050, 0x5538fb285988e502 // 370
	, WRITE__CMD, 0x70091030, 0x000000000000001e // 371
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 372
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 373
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 374
	, RDnCMP_CMD, 0x70091008, 0x000000000000195a // 375
	, RDnCMP_CMD, 0x70091010, 0x8e3619d8dc4070ce // 376
	, RDnCMP_CMD, 0x70091018, 0x4ea6b87a83d4fdbe // 377
	, RDnCMP_CMD, 0x70091020, 0x43868749662f1471 // 378
	, RDnCMP_CMD, 0x70091028, 0xe961048d9fea1784 // 379
	, WRITE__CMD, 0x70091040, 0xd2e7e119ee44a1fc // 380
	, WRITE__CMD, 0x70091048, 0x7aace62d439cb62b // 381
	, WRITE__CMD, 0x70091050, 0x5126f526228546ec // 382
	, WRITE__CMD, 0x70091030, 0x000000000000001f // 383
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 384
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 385
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 386
	, RDnCMP_CMD, 0x70091008, 0x0000000000001ca9 // 387
	, RDnCMP_CMD, 0x70091010, 0x8e3619d84e241a92 // 388
	, RDnCMP_CMD, 0x70091018, 0xbf60e5d76b94bbb1 // 389
	, RDnCMP_CMD, 0x70091020, 0x2df9b32226f9c106 // 390
	, RDnCMP_CMD, 0x70091028, 0x9c803ffad0ee0292 // 391
	, WRITE__CMD, 0x70091040, 0xbaf3ee18204aa909 // 392
	, WRITE__CMD, 0x70091048, 0x9b5e32d9ebdbcef1 // 393
	, WRITE__CMD, 0x70091050, 0xdcbf3f1d7a4fb4c8 // 394
	, WRITE__CMD, 0x70091030, 0x0000000000000020 // 395
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 396
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 397
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 398
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e50 // 399
	, RDnCMP_CMD, 0x70091010, 0x8e3619d807162fbc // 400
	, RDnCMP_CMD, 0x70091018, 0xc783cb019fb498b6 // 401
	, RDnCMP_CMD, 0x70091020, 0x6a663b61a599d2b4 // 402
	, RDnCMP_CMD, 0x70091028, 0x428075819c481996 // 403
	, WRITE__CMD, 0x70091040, 0xa62a4910373b63f5 // 404
	, WRITE__CMD, 0x70091048, 0x96d01c13713079f7 // 405
	, WRITE__CMD, 0x70091050, 0x0f6777dd01cb9306 // 406
	, WRITE__CMD, 0x70091030, 0x0000000000000021 // 407
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 408
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 409
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 410
	, RDnCMP_CMD, 0x70091008, 0x0000000000001f2c // 411
	, RDnCMP_CMD, 0x70091010, 0x8e3619d8238f352b // 412
	, RDnCMP_CMD, 0x70091018, 0xfbf25c6ae5a48935 // 413
	, RDnCMP_CMD, 0x70091020, 0xa0316df3edd6a495 // 414
	, RDnCMP_CMD, 0x70091028, 0xb9a8af4e76f1d031 // 415
	, WRITE__CMD, 0x70091040, 0x8cf7fffa5678f8cf // 416
	, WRITE__CMD, 0x70091048, 0xc9815cc5652d2ecf // 417
	, WRITE__CMD, 0x70091050, 0x00a853c511ea4cca // 418
	, WRITE__CMD, 0x70091030, 0x0000000000000022 // 419
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 420
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 421
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 422
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e5b // 423
	, RDnCMP_CMD, 0x70091010, 0x8e3619d831c3b860 // 424
	, RDnCMP_CMD, 0x70091018, 0x65ca97df58ac81f4 // 425
	, RDnCMP_CMD, 0x70091020, 0x1ec4bacd0e41c7f6 // 426
	, RDnCMP_CMD, 0x70091028, 0x243b8bb0c0877db4 // 427
	, WRITE__CMD, 0x70091040, 0x91b3fb348b80aa11 // 428
	, WRITE__CMD, 0x70091048, 0x2a64d63544838325 // 429
	, WRITE__CMD, 0x70091050, 0xbee20e2a96d6060e // 430
	, WRITE__CMD, 0x70091030, 0x0000000000000023 // 431
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 432
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 433
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 434
	, RDnCMP_CMD, 0x70091008, 0x00000000000012e1 // 435
	, RDnCMP_CMD, 0x70091010, 0x8e3619d838e5fec5 // 436
	, RDnCMP_CMD, 0x70091018, 0xaad6f20586288594 // 437
	, RDnCMP_CMD, 0x70091020, 0x490a6b6a1f31521a // 438
	, RDnCMP_CMD, 0x70091028, 0x1b169d168f2e92ab // 439
	, WRITE__CMD, 0x70091040, 0x3bfdab33937c3ccc // 440
	, WRITE__CMD, 0x70091048, 0x5ba677221b5c33c0 // 441
	, WRITE__CMD, 0x70091050, 0x9851863540eb252b // 442
	, WRITE__CMD, 0x70091030, 0x0000000000000024 // 443
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 444
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 445
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 446
	, RDnCMP_CMD, 0x70091008, 0x0000000000001974 // 447
	, RDnCMP_CMD, 0x70091010, 0x8e3619d83c76dd97 // 448
	, RDnCMP_CMD, 0x70091018, 0x4d58c0e8e96a87a4 // 449
	, RDnCMP_CMD, 0x70091020, 0x1c65a11ba6b526e0 // 450
	, RDnCMP_CMD, 0x70091028, 0x5f58c303385f173a // 451
	, WRITE__CMD, 0x70091040, 0xccedafdde7da1929 // 452
	, WRITE__CMD, 0x70091048, 0x149065133eb0bc0c // 453
	, WRITE__CMD, 0x70091050, 0xe57506d0be286213 // 454
	, WRITE__CMD, 0x70091030, 0x0000000000000025 // 455
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 456
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 457
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 458
	, RDnCMP_CMD, 0x70091008, 0x0000000000001e5b // 459
	, RDnCMP_CMD, 0x70091010, 0x8e3619d83e3f4c3e // 460
	, RDnCMP_CMD, 0x70091018, 0x3e9fd99e5ecb86bc // 461
	, RDnCMP_CMD, 0x70091020, 0xac16f00dc2abedcc // 462
	, RDnCMP_CMD, 0x70091028, 0xaaafecbda359b059 // 463
	, WRITE__CMD, 0x70091040, 0xe1b7fa0e3f71481e // 464
	, WRITE__CMD, 0x70091048, 0x4d1bd4be81d4b9fd // 465
	, WRITE__CMD, 0x70091050, 0x35d50ed45f2c0efa // 466
	, WRITE__CMD, 0x70091030, 0x0000000000000001 // 467
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 468
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 469
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 470
	, RDnCMP_CMD, 0x70091008, 0x0000000000001907 // 471
	, RDnCMP_CMD, 0x70091010, 0x924110552bd74e7f // 472
	, RDnCMP_CMD, 0x70091018, 0xc62d21cd7f83b3f9 // 473
	, RDnCMP_CMD, 0x70091020, 0x3a957bdbc127eecc // 474
	, RDnCMP_CMD, 0x70091028, 0xdb8a7a8e3a946144 // 475
	, WRITE__CMD, 0x70091030, 0x0000000000000000 // 476
	, WRITE__CMD, 0x70091040, 0x46caa7e06d9f77d7 // 477
	, WRITE__CMD, 0x70091048, 0xad4618d667b1a80c // 478
	, WRITE__CMD, 0x70091050, 0xae37b515ac6a50d6 // 479
	, WRITE__CMD, 0x70091030, 0x0000000000000001 // 480
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 481
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 482
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 483
	, RDnCMP_CMD, 0x70091008, 0x0000000000001907 // 484
	, RDnCMP_CMD, 0x70091010, 0x924110552bd74e7f // 485
	, RDnCMP_CMD, 0x70091018, 0xc62d21cd7f83b3f9 // 486
	, RDnCMP_CMD, 0x70091020, 0x5f00751e024d5bb2 // 487
	, RDnCMP_CMD, 0x70091028, 0xb1e7781fb87872c5 // 488
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 489
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 490
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 491
	, RDnCMP_CMD, 0x70091008, 0x0000000000000527 // 492
	, RDnCMP_CMD, 0x70091010, 0xa4cc77e4c4a5df08 // 493
	, RDnCMP_CMD, 0x70091018, 0x1e90b013d5d49f81 // 494
	, RDnCMP_CMD, 0x70091020, 0x0dc01c151ffb4b10 // 495
	, RDnCMP_CMD, 0x70091028, 0xe269606e20a2a626 // 496
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 497
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 498
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 499
	, RDnCMP_CMD, 0x70091008, 0x0000000000001289 // 500
	, RDnCMP_CMD, 0x70091010, 0x23cdcb727884e90a // 501
	, RDnCMP_CMD, 0x70091018, 0x711597ada3763449 // 502
	, RDnCMP_CMD, 0x70091020, 0x4ce3b3157c0180b4 // 503
	, RDnCMP_CMD, 0x70091028, 0xa6718f6d454d6cb4 // 504
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 505
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 506
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 507
	, RDnCMP_CMD, 0x70091008, 0x0000000000001ead // 508
	, RDnCMP_CMD, 0x70091010, 0x5edfbb670d674a49 // 509
	, RDnCMP_CMD, 0x70091018, 0x62fc006ac9201982 // 510
	, RDnCMP_CMD, 0x70091020, 0x746595f7f8338a16 // 511
	, RDnCMP_CMD, 0x70091028, 0x5a48585552459659 // 512
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 513
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 514
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 515
	, RDnCMP_CMD, 0x70091008, 0x000000000000022a // 516
	, RDnCMP_CMD, 0x70091010, 0x7bf71bced1a5f16a // 517
	, RDnCMP_CMD, 0x70091018, 0x11080cfc2118bf81 // 518
	, RDnCMP_CMD, 0x70091020, 0x2ee339e414213dcb // 519
	, RDnCMP_CMD, 0x70091028, 0xcde3e3ac43e2d9e5 // 520
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 521
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 522
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 523
	, RDnCMP_CMD, 0x70091008, 0x0000000000001647 // 524
	, RDnCMP_CMD, 0x70091010, 0x36e3c12c443bd867 // 525
	, RDnCMP_CMD, 0x70091018, 0x8255c06d871c4469 // 526
	, RDnCMP_CMD, 0x70091020, 0xe719e81c631d9a49 // 527
	, RDnCMP_CMD, 0x70091028, 0xd34c3cd30973d75e // 528
	, WRITE__CMD, 0x70091000, 0x0000000000000001 // 529
	, WRITE__CMD, 0x70091000, 0x0000000000000000 // 530
	, RDSPIN_CMD, 0x70091000, 0x0000000000000002, 0x2, 0x1f4 // 531
	, RDnCMP_CMD, 0x70091008, 0x00000000000014fd // 532
	, RDnCMP_CMD, 0x70091010, 0x67ffb30f00da43fe // 533
	, RDnCMP_CMD, 0x70091018, 0x8231de3118c2ce55 // 534
	, RDnCMP_CMD, 0x70091020, 0xe4aed9c812153b6b // 535
	, RDnCMP_CMD, 0x70091028, 0xe8b74f06d4e5f0f2 // 536
};

#define GPS_REDACT_adrBase 0x0070090000
#define GPS_REDACT_adrSize 0x10000
#define GPS_REDACT_size 1700
#define GPS_REDACT_cmdCnt4Single 31
#define GPS_REDACT_totalCommands 536
#endif