/*##############################################################################

    HPCC SYSTEMS software Copyright (C) 2012 HPCC Systems.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
############################################################################## */

integer8 xvalue := 999 : stored('xvalue');

integer mapValue(integer search) := case(search,
            28253821=>5, 2398199905=>5, 4094386965=>5, 72045757=>5, 1003138110=>5, 1418691519=>5, 1880986192=>5, 3943894554=>5, 2906332750=>5, 472514344=>5, 1464556598=>5,
            98995558=>5, 1774144555=>5, 2698382519=>5, 3051835101=>5, 1166126362=>5, 4107381257=>5, 1803853464=>5, 2408001847=>5, 1986044889=>5, 3527572000=>5, 383800657=>5,
            -1220082977=>5, 586047105=>5, 1474189304=>5, 3573438990=>5, 702615138=>5, 2382524875=>5, 2288233762=>5, 4087378570=>5, 857480464=>5, 167490308=>5, 2742388734=>5,
            911571794=>5, -1687636974=>5, 3532789513=>5, 808880936=>5, 1011084984=>5, 504683403=>5, 2212385357=>5, 2222617711=>5, 1225080783=>5, 2240010175=>5, 3626870599=>5,
            4037659842=>5, 1541888783=>5, -3752749070=>5, 3127162333=>5, 3329142712=>5, 1273299185=>5, 1393791511=>5, 3286983031=>5, 2928132103=>5, 3225913783=>5, 1817758105=>5,
            3942576142=>5, 1559372095=>5, 1502277201=>5, -2078228207=>5, 4034878206=>5, 1521771557=>5, 2203742423=>5, 1143736440=>5, 191572322=>5, 2884521761=>5, 2291346150=>5,
            1301182304=>5, 970901226=>5, 963433073=>5, 4150655778=>5, -1385337994=>5, 1515379226=>5, 3838024715=>5, 2076279415=>5, 847654542=>5, 293438862=>5, 2681176081=>5,
            845529510=>5, 2890273572=>5, 2688875020=>5, 1495395012=>5, 877770809=>5, -2956750231=>5, 3413529055=>5, 29118596=>5, 2486102286=>5, 116489132=>5, 3069939850=>5,
            1981739040=>5, 2637178179=>5, 3805339576=>5, 3423673932=>5, 810181801=>5, 2918696087=>5, -2087993578=>5, 759316116=>5, 2470870267=>5, 4030544937=>5, 1322350986=>5,
            2439440208=>5, 3988558552=>5, 2633883919=>5, 1710115912=>5, 2168338288=>5, 2911837181=>5, 1696149819=>5, -21946530=>5, 4013677237=>5, 2850362275=>5, 2281721526=>5,
            1196223362=>5, 558493210=>5, 1210479618=>5, 1343930082=>5, 2428509284=>5, 1788376147=>5, 979260005=>5, 2951949991=>5, -2939905760=>5, 3834233840=>5, 2437946675=>5,
            2487659534=>5, 1778761023=>5, 1306815334=>5, 2508535952=>5, 119115365=>5, 753430417=>5, 984839847=>5, 441268628=>5, 970376342=>5, -3556332022=>5, 3150320550=>5,
            2490356019=>5, 2702391369=>5, 1600791676=>5, 3692841564=>5, 3487949230=>5, 2392429632=>5, 1380785718=>5, 1351381946=>5, 18850151=>5, 3969069788=>5, 162996565=>5,
            840899854=>5, 1389374234=>5, 2596009327=>5, 4227791184=>5, 740729028=>5, 1375806965=>5, 2798489348=>5, 2946887332=>5, 1941055300=>5, 932481793=>5, -1478597828=>5,
            1692942609=>5, 1417012457=>5, 813913401=>5, 3298731757=>5, 1283791885=>5, 1536360479=>5, 1065824663=>5, 3570773460=>5, 3567529922=>5, 888914920=>5, 2186622315=>5,
            3742756247=>5, 1355558371=>5, 1880542439=>5, 4174802027=>5, 394362355=>5, 677801245=>5, 3856307074=>5, 1194197066=>5, 1337805876=>5, 2554895541=>5, 2394083925=>5,
            2779788064=>5, 2302705932=>5, 1794923210=>5, 2097937623=>5, 4041440085=>5, 2542488411=>5, 2521344192=>5, 2988404973=>5, 488266395=>5, 2823326493=>5, 3369345661=>5,
            977671684=>5, 4063629584=>5, 3508103927=>5, 3864467110=>5, 3938848620=>5, 2779508031=>5, 50045631=>5, 690448606=>5, 2598999434=>5, 300614386=>5, 2246475916=>5,
            4094808841=>5, 551353829=>5, 963390354=>5, 2080797286=>5, 3527581648=>5, 732785883=>5, 3000905277=>5, 143218366=>5, 2695155180=>5, 3636538090=>5, 82494934=>5,
            1219177647=>5, 1810556577=>5, 1695163034=>5, 3735709008=>5, 208454587=>5, 742506392=>5, 1212247654=>5, 3549796777=>5, 2085871214=>5, 4117096055=>5, 292897116=>5,
            3584251829=>5, 408733944=>5, 2511505781=>5, 682827392=>5, 694448961=>5, 313102881=>5, 3604370829=>5, 1687473837=>5, 2985258792=>5, 1461751178=>5, 1284479489=>5,
            1252099400=>5, 4025172941=>5, 3819912625=>5, 1300025972=>5, 2012608887=>5, 2555838901=>5, 268247953=>5, 436385090=>5, 3000875097=>5, 1930565001=>5, 2369967488=>5,
            2839261787=>5, 1651972620=>5, 3154937217=>5, 1766146547=>5, 1522415198=>5, 2644565931=>5, 1270605531=>5, 1982867802=>5, 81451903=>5, 3404927113=>5, 739770592=>5,
            3291727010=>5, 2206109268=>5, 1693891335=>5, 881726944=>5, 3529646180=>5, 1241832212=>5, 1911143598=>5, 3525815074=>5, 3400467254=>5, 2668810026=>5, 2179369026=>5,
            3492168372=>5, 56240743=>5, 438550127=>5, 3765756470=>5, 1002202239=>5, 3619310040=>5, 3348872442=>5, 2244162349=>5, 1377709348=>5, 3404621776=>5, 3940988421=>5,
            480054217=>5, 1148808828=>5, 939398322=>5, 3420758166=>5, 2657441646=>5, 1521193978=>5, 4048815882=>5, 4157529813=>5, 3067290045=>5, 3801010123=>5, 496658309=>5,
            1310620711=>5, 2950671757=>5, 2296600784=>5, 2021019533=>5, 2978295557=>5, 795267406=>5, 1813574687=>5, 940777985=>5, 2063301989=>5, 3895370061=>5, 2164624873=>5,
            180743150=>5, 2139319124=>5, 1437387=>5, 2596305328=>5, 2526160245=>5, 1102660734=>5, 4132302311=>5, 3729834616=>5, 251749148=>5, 3603052608=>5, 3212862760=>5,
            130557527=>5, 3768349059=>5, 328284918=>5, 3327545749=>5, 163805893=>5, 4064421364=>5, 3738574201=>5, 1515618838=>5, 2204179121=>5, 3777306697=>5, 1971315270=>5,
            2231776986=>5, 1443306813=>5, 2098776471=>5, 1840821554=>5, 56072599=>5, 3810761984=>5, 2145811289=>5, 507422893=>5, 3969994185=>5, 869276282=>5, 2951938793=>5,
            1671663711=>5, 955632579=>5, 2967691280=>5, 3731902656=>5, 1605269752=>5, 3778995014=>5, 1729474803=>5, 957825090=>5, 910515436=>5, 1777725785=>5, 788585288=>5,
            2708340638=>5, 4215994851=>5, 3277649248=>5, 45723104=>5, 626161414=>5, 3764900924=>5, 832520112=>5, 1690690199=>5, 3397656447=>5, 3252201082=>5, 1993128045=>5,
            884818687=>5, 3671777069=>5, 980763752=>5, 1959660073=>5, 433058715=>5, 3414584061=>5, 954060749=>5, 1605424230=>5, 3559457958=>5, 1721143277=>5, 960010866=>5,
            210795907=>5, 837843447=>5, 2572337627=>5, 1690867352=>5, 407229180=>5, 3289069201=>5, 57094713=>5, 1146579137=>5, 3283896585=>5, 229400175=>5, 3506401541=>5,
            3649303113=>5, 3412287598=>5, 866595546=>5, 3054709858=>5, 302847412=>5, 4036009406=>5, 63293316=>5, 1200808049=>5, 4283626701=>5, 1771946696=>5, 3264717969=>5,
            1431166894=>5, 818725415=>5, 2363731730=>5, 2917979624=>5, 1986096816=>5, 2098831739=>5, 2182372263=>5, 2935016827=>5, 3750704297=>5, 2570447598=>5, 3839444119=>5,
            3920915753=>xvalue,  10);

ds8 := dataset('ds', {unsigned8 ukey, integer8 skey}, thor);

output(ds8(mapValue(skey) = 5));

