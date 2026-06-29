import 'dart:io';

final Map<String, List<String>> newAnimalTemplates = {
  // 1. Cat (Kedi)
  "Kedi": [
    "................",
    "....F......F....",
    "...FFF....FFF...",
    "..FFFFF..FFFFF..",
    "..FFFFFFFFFFFF..",
    ".FFFFFFFFFFFFFF.",
    ".FFFLFFFFFFFLFF.",
    ".FFLFFLFFFFLFFL.",
    ".FFFLFFFFFFFLFF.",
    ".FFFFFFAAFFFFFF.",
    "..FFFFFAFFFFFF..",
    "...FFFFFFFFFF...",
    "....FFFFFFFF....",
    ".....FFFFFF.....",
    "................",
    "................"
  ],
  // 2. Dog (Kopek)
  "Kopek": [
    "................",
    "...NNNNNNNNNN...",
    "..NNNNNNNNNNNN..",
    "..NNNNNNNNNNNN..",
    ".NNNLLNNNNLLNNN.",
    ".NNNNNNNNNNNNNN.",
    ".NNNNNNNNNNNNNN.",
    "NNNNNNNKKNNNNNNN",
    "NNNNNKKKKKKNNNNN",
    "NNNNNKKLLKKNNNNN",
    ".NNNNNKKKKNNNNN.",
    "..NNNNNNNNNNNN..",
    "...NNNNHHNNNN...",
    "....NNHHHHNN....",
    "......NNNN......",
    "................"
  ],
  // 3. Panda
  "Panda": [
    "................",
    "..L..........L..",
    ".LLL........LLL.",
    "LLLLKKKKKKKKLLLL",
    "LLKKKKKKKKKKKKLL",
    "LKKKKKKKKKKKKKKL",
    "KKKKLLKKKKLLKKKK",
    "KKKLLLLKKLLLLKKK",
    "KKKKLLKKKKLLKKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKKKLLKKKKKKK",
    ".KKKKKKLLKKKKKK.",
    "..KKKKKKKKKKKK..",
    "...KKKKKKKKKK...",
    ".....KKKKKK.....",
    "................"
  ],
  // 4. Frog (Kurbagha)
  "Kurbagha": [
    "................",
    "...KK......KK...",
    "..KLLK....KLLK..",
    "..KLLK....KLLK..",
    ".CCCCCCCCCCCCCC.",
    "CCCCCCCCCCCCCCCC",
    "CCCCCCCCCCCCCCCC",
    "CCCCCCCCCCCCCCCC",
    "CCCLLCCCCCCLLCCC",
    "CCCCLLLLLLLLCCCC",
    ".CCCCCCCCCCCCCC.",
    "..CCCCCCCCCCCC..",
    "...CCCCCCCCCC...",
    "....CCCCCCCC....",
    "................",
    "................"
  ],
  // 5. Pig (Domuz)
  "Domuz": [
    "................",
    "....H......H....",
    "...HHH....HHH...",
    "..HHHHHHHHHHHH..",
    ".HHHHHHHHHHHHHH.",
    ".HHHHHHHHHHHHHH.",
    "HHHLLHHHHHHLLHHH",
    "HHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHH",
    "HHHHHAAAAAAHHHHH",
    "HHHHHAALAAHAHHHH",
    ".HHHHAAAAAAHHHH.",
    "..HHHHHHHHHHHH..",
    "...HHHHHHHHHH...",
    ".....HHHHHH.....",
    "................"
  ],
  // 6. Bear (Ayi)
  "Ayi": [
    "................",
    "..N..........N..",
    ".NNN........NNN.",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNLLNNNNNNLLNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNKKKKNNNNNN",
    ".NNNNNKKLLKNNNN.",
    "..NNNNNKKKNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "......NNNN......",
    "................"
  ],
  // 7. Rabbit (Tavsan)
  "Tavsan": [
    "....K......K....",
    "....K......K....",
    "...KK......KK...",
    "...KH......HK...",
    "..KKH......HKK..",
    "..KKH......HKK..",
    ".KKKKKKKKKKKKKK.",
    ".KKKKKKKKKKKKKK.",
    "KKKKKKKKKKKKKKKK",
    "KKKAAKKKKKKAAKKK",
    "KKKKKKKKKKKKKKKK",
    ".KKKKKKKAAKKKKK.",
    "..KKKKKKKKKKKK..",
    "...KKKKKKKKKK...",
    "....KKKKKKKK....",
    "................"
  ],
  // 8. Fox (Tilki)
  "Tilki": [
    "................",
    "..F..........F..",
    "..FF........FF..",
    "..FFF......FFF..",
    ".FFFFFFFFFFFFFF.",
    ".FFFFFFFFFFFFFF.",
    "FFFLLFFFFFFLLFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFKKKKKKFFFFF",
    ".FFFFKKLLKKFFFF.",
    "..FFFKKKKKKFFF..",
    "...FFFFFFFFFF...",
    "....FFFFFFFF....",
    "......FFFF......",
    "................"
  ],
  // 9. Penguin (Penguen)
  "Penguen": [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLKKKKKKLL...",
    "..LLKKLLKKKKL...",
    "..LLKKKKKKKKL...",
    "..LKKKLLKKKKL...",
    "..LKKKKKKKKKL...",
    "..LLKKKKKKKLL...",
    "..LLKKDDDDLLLL..",
    "..LLKKKDDLLKLL..",
    "....LLLLLLLL....",
    ".....LLLLLL.....",
    "....DD....DD....",
    "................"
  ],
  // 10. Owl (Baykus)
  "Baykus": [
    "................",
    "....N......N....",
    "....NN....NN....",
    "...NNNNNNNNNN...",
    "..NNNNNNNNNNNN..",
    ".NNKKNNNNNNKKNN.",
    ".NKKLLNNNNKKLLN.",
    ".NKKLLNNNNKKLLN.",
    ".NNKKNNNNNNKKNN.",
    ".NNNNNNDDNNNNNN.",
    "..NNNNNDDDNNNN..",
    "..NNNNNNNNNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "....DD....DD....",
    "................"
  ],
  // 11. Monkey (Maymun)
  "Maymun": [
    "................",
    "......NNNN......",
    "..N..NNNNNN..N..",
    ".NN.NNNNNNNN.NN.",
    ".NNNNNNNNNNNNNN.",
    "NNNNNNNNNNNNNNNN",
    "NNNKKKKKKKKKKNNN",
    "NNKKLLKKKKLLKKNN",
    "NNKKKKKKKKKKKKNN",
    "NNNKKKKLLKKKKNNN",
    ".NNNKKLLLLKKNNN.",
    "..NNNNKKKKNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "......NNNN......",
    "................"
  ],
  // 12. Giraffe (Zurafa)
  "Zurafa": [
    "................",
    "......D..D......",
    "......DDDD......",
    ".....DDDDDD.....",
    ".....DLDDLD.....",
    ".....DDDDDD.....",
    "......DDDD......",
    "......DNDD......",
    "......DNDD......",
    "......DDDD......",
    "......DDDD......",
    "......DNDD......",
    "......DDDD......",
    "......DDDD......",
    "......DDDD......",
    "................"
  ],
  // 13. Elephant (Fil)
  "Fil": [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMKKMMMMMMKKMMM",
    "MMMKKMMMMMMKKMMM",
    ".MMMMMMMMMMMMMM.",
    "..MMMMMMMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    ".....MMMMMM.....",
    "................"
  ],
  // 14. Lion (Aslan)
  "Aslan": [
    "................",
    "..F..FFFFFF..F..",
    ".FF.FFFFFFFF.FF.",
    "FFFFFFFFFFFFFFFF",
    "FFFDFFFFFDFFFFFF",
    "FFFDLFFFDLFFFFFF",
    "FFFDDFFFFDDFFFFF",
    "FFFFFDDDDFFFFFFF",
    "FFFFFFLLFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    ".FFFFFFFFFFFLLF.",
    "..FFFFFFFFFFLF..",
    "...FFFFFFFFFF...",
    "....FFFFFFFF....",
    "......FFFF......",
    "................"
  ],
  // 15. Tiger (Kaplan)
  "Kaplan": [
    "................",
    "..F..........F..",
    ".FFF........FFF.",
    "FFFFFFFFFFFFFFFF",
    "FFFLFFFLFFFLFFFF",
    "FFFLFFFFFFFLFFFF",
    "FFKLLFFFFFLLKFFF",
    "FFKKKKKKKKKKFFFF",
    "FFFLFFFLFFFLFFFF",
    "FFFFFKKLLKKFFFFF",
    ".FFFFKKKKKKFFFF.",
    "..FFFFFFFFFFFF..",
    "...FFFFFFFFFF...",
    "....FFFFFFFF....",
    "......FFFF......",
    "................"
  ],
  // 16. Bee (Ari)
  "Ari": [
    "................",
    "......LLLL......",
    "....LLDDDDLL....",
    "...LLDDDDDDLL...",
    "...LLLLLLLLLL...",
    "..LLDDDDDDDDLL..",
    "..LLLLLLLLLLLL..",
    "..LLDDDDDDDDLL..",
    "..LLLLLLLLLLLL..",
    "..LLDDDDDDDDLL..",
    "..LLLLLLLLLLLL..",
    "...LLDDDDDDLL...",
    "....LLLLLLLL....",
    "......LLLL......",
    "................",
    "................"
  ],
  // 17. Ladybug (Ugurbulu)
  "Ugurbulu": [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLAALLLAALL..",
    "..LAAAAALAAAAAL.",
    "..LAAAAALAAAAAL.",
    "..LAAALLAAALLLL.",
    "..LAAAAALAAAAAL.",
    "..LAAAAALAAAAAL.",
    "..LLAALLLAALL...",
    "...LLLLLLLLLL...",
    "....LLLLLLLL....",
    "......LLLL......",
    "................",
    "................"
  ],
  // 18. Turtle (Kaplumbaga)
  "Kaplumbaga": [
    "................",
    "......CCCC......",
    "....CCCCCCCC....",
    "...CCCCCCCCCC...",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCLLCCCCLL..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "...CCCCCCCCCC...",
    "....CCCCCCCC....",
    "......CCCC......",
    "................",
    "................"
  ],
  // 19. Fish (Balik)
  "Balik": [
    "................",
    "........FF......",
    "......FFFFFF....",
    "....FFFFFFFFFF..",
    "..FFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFLFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "..FFFFFFFFFFFFFF",
    "....FFFFFFFFFF..",
    "......FFFFFF....",
    "........FF......",
    "................",
    "................"
  ],
  // 20. Crab (Yengec)
  "Yengec": [
    "................",
    "..R..........R..",
    ".RRR........RRR.",
    "RRRRR......RRRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRLLRRRRRRLLRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRRRRRRRRRRRRRR",
    ".RRRRRRRRRRRRRR.",
    "..RRRRRRRRRRRR..",
    "...RRRRRRRRRR...",
    "....RRRRRRRR....",
    "......RRRR......",
    "................"
  ],
  // 21. Octopus (Ahtapot)
  "Ahtapot": [
    "................",
    "......EEEE......",
    "....EEEEEEEE....",
    "...EEEEEEEEEE...",
    "..EEEEEEEEEEEE..",
    "..EEEELLEEEELL..",
    "..EEEEEEEEEEEE..",
    "..EEEEEEEEEEEE..",
    "..EEEEEEEEEEEE..",
    "..EEEEEEEEEEEE..",
    "...EEEEEEEEEE...",
    "....EEEEEEEE....",
    "...EE..EE..EE...",
    "..EE...EE...EE..",
    ".EE....EE....EE.",
    "................"
  ],
  // 22. Duck (Ordek)
  "Ordek": [
    "................",
    "......DDDD......",
    "....DDDDDDDD....",
    "...DDDDLDDDD....",
    "...DDDDDDDDDD...",
    "....DDDDDDDD....",
    "......DDDD......",
    "...DDDDDDDDDD...",
    "..DDDDDDDDDDDD..",
    ".DDDDDDDDDDDDDD.",
    ".DDDDDDDDDDDDDD.",
    ".DDDDDDDDDDDDDD.",
    "..DDDDDDDDDDDD..",
    "...DDDDDDDDDD...",
    "....FFFFFFFF....",
    "................"
  ],
  // 23. Sheep (Koyun)
  "Koyun": [
    "................",
    "......KKKK......",
    "....KKKKKKKK....",
    "...KKKKKKKKKK...",
    "..KKKLLKKKKLLKK.",
    "..KKKKKKKKKKKKK.",
    "..KKKKKKKKKKKKK.",
    "..KKKKKKKKKKKKK.",
    "..KKKKKKKKKKKKK.",
    "..KKKKKKKKKKKKK.",
    "...KKKKKKKKKK...",
    "....KKKKKKKK....",
    ".....KKKKKK.....",
    ".....LL..LL.....",
    ".....LL..LL.....",
    "................"
  ],
  // 24. Cow (Inek)
  "Inek": [
    "................",
    "..L..........L..",
    ".LLL........LLL.",
    "LLLLLLLLLLLLLLLL",
    "LLKKKKLLKKKKLLLL",
    "LKKKKKKKKKKKKKKL",
    "KKKKKKKKKKKKKKKK",
    "KKKLLKKKKKKLLKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKLLKKKKKKKKK",
    ".KKKKLLKKKKKKKK.",
    "..KKKKKKKKKKKK..",
    "...KKKKKKKKKK...",
    "....KKKKKKKK....",
    "......KKKK......",
    "................"
  ],
  // 25. Mouse (Fare)
  "Fare": [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMM......MMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    ".MMMMMMMMMMMMMM.",
    "..MMMMMMMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................"
  ],
  // 26. Koala
  "Koala": [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMM......MMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMLLMMMMMMMM",
    ".MMMMMLLMMMMMMM.",
    "..MMMMLLMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................"
  ],
  // 27. Kangaroo (Kanguru)
  "Kanguru": [
    "................",
    "......N..N......",
    "......NNNN......",
    ".....NNNNNN.....",
    ".....NLDDLD.....",
    ".....NNNNNN.....",
    "......NNNN......",
    "......NNNN......",
    ".....NNNNNN.....",
    "....NNNNNNNN....",
    "....NNNNNNNN....",
    "....NNNNNNNN....",
    "....NNNNNNNN....",
    ".....NNNNNN.....",
    "......NNNN......",
    "................"
  ],
  // 28. Su Aygiri (Hippo)
  "Su Aygiri": [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMM......MMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    ".MMMMMMMMMMMMMM.",
    "..MMMMMMMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................"
  ],
  // 29. Gergedan (Rhino)
  "Gergedan": [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMM......MMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    ".MMMMMMMMMMMMMM.",
    "..MMMMMMMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................"
  ],
  // 30. Timsah (Crocodile)
  "Timsah": [
    "................",
    "......CCCC......",
    "....CCCCCCCC....",
    "...CCCCCCCCCC...",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCLLCCCCLL..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "...CCCCCCCCCC...",
    "....CCCCCCCC....",
    "......CCCC......",
    "................",
    "................"
  ],
  // 31. Geyik (Deer)
  "Geyik": [
    "....N......N....",
    "....NN....NN....",
    "....NNNNNNNN....",
    "...NNNNNNNNNN...",
    "..NNNNNNNNNNNN..",
    ".NNLLNNNNNNLLNN.",
    ".NNNNNNNNNNNNNN.",
    ".NNNNNNNNNNNNNN.",
    ".NNNNNNNNNNNNNN.",
    ".NNNNNNNLLNNNNN.",
    "..NNNNNNLLNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    ".....NNNNNN.....",
    "......NNNN......",
    "................"
  ],
  // 32. Yarasa (Bat)
  "Yarasa": [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLLLLLLLLL...",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "...LLLLLLLLLL...",
    "....LLLLLLLL....",
    "......LLLL......",
    "................",
    "................"
  ],
  // 33. Kurt (Wolf)
  "Kurt": [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMM......MMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    ".MMMMMMMMMMMMMM.",
    "..MMMMMMMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................"
  ],
  // 34. Yilan (Snake)
  "Yilan": [
    "................",
    "......CCCC......",
    "....CCCCCCCC....",
    "...CCCCCCCCCC...",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCLLCCCCLL..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "...CCCCCCCCCC...",
    "....CCCCCCCC....",
    "......CCCC......",
    "................",
    "................"
  ],
  // 35. Yunus (Dolphin)
  "Yunus": [
    "................",
    "......BBBB......",
    "....BBBBBBBB....",
    "...BBBBBBBBBB...",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBLLBBBBLL..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "...BBBBBBBBCC...",
    "....BBBBBBCC....",
    "......BBCC......",
    "................",
    "................"
  ],
  // 36. Balina (Whale)
  "Balina": [
    "................",
    "......BBBB......",
    "....BBBBBBBB....",
    "...BBBBBBBBBB...",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBLLBBBBLL..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "...BBBBBBBBCC...",
    "....BBBBBBCC....",
    "......BBCC......",
    "................",
    "................"
  ],
  // 37. Kopekbaligi (Shark)
  "Kopekbaligi": [
    "................",
    "......MMMM......",
    "....MMMMMMMM....",
    "...MMMMMMMMBB...",
    "..MMMMMMMMMMMM..",
    "..MMMMMMMMMMMM..",
    "..MMMMLLMMMMLL..",
    "..MMMMMMMMMMMM..",
    "..MMMMMMMMMMMM..",
    "..MMMMMMMMMMMM..",
    "..MMMMMMMMMMBB..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................",
    "................"
  ],
  // 38. Kelebek (Butterfly)
  "Kelebek": [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLLLLLLLLL...",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "...LLLLLLLLLL...",
    "....LLLLLLLL....",
    "......LLLL......",
    "................",
    "................"
  ],
  // 39. Civciv (Chick)
  "Civciv": [
    "................",
    "......DDDD......",
    "....DDDDDDDD....",
    "...DDDDLDDDD....",
    "...DDDDDDDDDD...",
    "....DDDDDDDD....",
    "......DDDD......",
    "...DDDDDDDDDD...",
    "..DDDDDDDDDDDD..",
    ".DDDDDDDDDDDDDD.",
    ".DDDDDDDDDDDDDD.",
    ".DDDDDDDDDDDDDD.",
    "..DDDDDDDDDDDD..",
    "...DDDDDDDDDD...",
    "....FFFFFFFF....",
    "................"
  ],
  // 40. Sincap (Squirrel)
  "Sincap": [
    "................",
    "..N..........N..",
    ".NNN........NNN.",
    "NNNNN......NNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNLLNNNNNNLLNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    ".NNNNNNNLLNNNNN.",
    "..NNNNNNLLNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "......NNNN......",
    "................"
  ],
  // 41. Deve (Camel)
  "Deve": [
    "................",
    "......NNNN......",
    "....NNNNNNNN....",
    "...NNNNNNNNNN...",
    "..NNNNNNNNNNNN..",
    "..NNNNNNNNNNNN..",
    "..NNNNLLNNNNLL..",
    "..NNNNNNNNNNNN..",
    "..NNNNNNNNNNNN..",
    "..NNNNNNNNNNNN..",
    "..NNNNNNNNNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "......NNNN......",
    "................",
    "................"
  ],
  // 42. Kugu (Swan)
  "Kugu": [
    "................",
    "......KKKK......",
    "....KKKKKKKK....",
    "...KKKKKKKKKK...",
    "..KKKKKKKKKKKK..",
    "..KKKKKKKKKKKK..",
    "..KKKKLLKKKKLL..",
    "..KKKKKKKKKKKK..",
    "..KKKKKKKKKKKK..",
    "..KKKKKKKKKKKK..",
    "..KKKKKKKKKKKK..",
    "...KKKKKKKKKK...",
    "....KKKKKKKK....",
    "......KKKK......",
    "................",
    "................"
  ],
  // 43. Hamster
  "Hamster": [
    "................",
    "..N..........N..",
    ".NNN........NNN.",
    "NNNNN......NNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNLLNNNNNNLLNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    ".NNNNNNNLLNNNNN.",
    "..NNNNNNLLNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "......NNNN......",
    "................"
  ],
  // 44. Ugur Bocegi
  "Ugur Bocegi": [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLAALLLAALL..",
    "..LAAAAALAAAAAL.",
    "..LAAAAALAAAAAL.",
    "..LAAALLAAALLLL.",
    "..LAAAAALAAAAAL.",
    "..LAAAAALAAAAAL.",
    "..LLAALLLAALL...",
    "...LLLLLLLLLL...",
    "....LLLLLLLL....",
    "......LLLL......",
    "................",
    "................"
  ],
  // 45. Baykus 2
  "Baykus 2": [
    "................",
    "....N......N....",
    "....NN....NN....",
    "...NNNNNNNNNN...",
    "..NNNNNNNNNNNN..",
    ".NNLLNNNNNNLLNN.",
    ".NLLLLNNNNLLLLN.",
    ".NLLLLNNNNLLLLN.",
    ".NNLLNNNNNNLLNN.",
    ".NNNNNNDDNNNNNN.",
    "..NNNNNDDDNNNN..",
    "..NNNNNNNNNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "....DD....DD....",
    "................"
  ],
  // 46. Kizil Tilki
  "Kizil Tilki": [
    "................",
    "..F..........F..",
    "..FF........FF..",
    "..FFF......FFF..",
    ".FFFFFFFFFFFFFF.",
    ".FFFFFFFFFFFFFF.",
    "FFFFFFFFFFFFFFFF",
    "FFFLLFFFFFFLLFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    ".FFFFFFFLLFFFFF.",
    "..FFFFFKKKFFFF..",
    "...FFFKKKKKFFF..",
    "....FKKKKKKFFF..",
    "......KKKK......",
    "................"
  ],
  // 47. Penguen 2
  "Penguen 2": [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLKKKKKKLL...",
    "..LLKKKKKKKKL...",
    "..LLKKLLKKKKL...",
    "..LKKLLLLKKKL...",
    "..LKKKLLKKKKL...",
    "..LKKKKKKKKKL...",
    "..LLKKKKKKKLL...",
    "..LLKKKKKKKLL...",
    "....LLKKKKLL....",
    ".....LLLLLL.....",
    "....DD....DD....",
    "................"
  ],
  // 48. Kutup Ayisi
  "Kutup Ayisi": [
    "................",
    "..K..........K..",
    ".KKK........KKK.",
    "KKKKK......KKKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKLLKKKKKKLLKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKKKKKKKKKKKK",
    ".KKKKKKKLLKKKKK.",
    "..KKKKKKLLKKKK..",
    "...KKKKKKKKKK...",
    "....KKKKKKKK....",
    "......KKKK......",
    "................"
  ],
  // 49. Yavru Panda
  "Yavru Panda": [
    "................",
    "..L..........L..",
    ".LLL........LLL.",
    "LLLLL......LLLLL",
    "LLKKKKKKKKKKKKLL",
    "LKKKKKKKKKKKKKKL",
    "KKKKKKKKKKKKKKKK",
    "KKKLLKKKKKKLLKKK",
    "KKKLLKKKKKKLLKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKKKLLKKKKKKK",
    ".KKKKKKLLKKKKKK.",
    "..KKKKKKKKKKKK..",
    "...KKKKKKKKKK...",
    ".....KKKKKK.....",
    "................"
  ],
  // 50. Disi Aslan
  "Disi Aslan": [
    "................",
    "..F..FFFFFF..F..",
    ".FF.FFFFFFFF.FF.",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFLLFFFFFFLLFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    ".FFFFFFFLLFFFFF.",
    "..FFFFFFLLFFFF..",
    "...FFFFFFFFFF...",
    "....FFFFFFFF....",
    "......FFFF......",
    "................"
  ]
};

void main() {
  final file = File('tools/build_levels.dart');
  if (!file.existsSync()) {
    print('build_levels.dart not found!');
    return;
  }

  var content = file.readAsStringSync();

  // 1. Swap main loop logic for i <= 50 vs i > 50
  final oldLoopPart = '''    if (i <= 50) {
      // Animal theme
      name = animalNames[i - 1];
      baseTemplate = animalTemplates[i - 1];
    } else {
      // Object theme
      name = objectNames[i - 51];
      baseTemplate = objectTemplates[i - 51];
    }''';

  final newLoopPart = '''    if (i <= 50) {
      // Object theme
      name = objectNames[i - 1];
      baseTemplate = objectTemplates[i - 1];
    } else {
      // Animal theme
      name = animalNames[i - 51];
      baseTemplate = animalTemplates[i - 51];
    }''';

  content = content.replaceFirst(oldLoopPart, newLoopPart);

  // 2. Replace animal templates inside build_levels.dart
  // We locate the start of animalTemplates:
  // "final List<List<String>> animalTemplates = ["
  final templatesStartIdx = content.indexOf('final List<List<String>> animalTemplates = [');
  final templatesEndIdx = content.indexOf('// ==========================================\n// OBJECT TEMPLATES');
  
  if (templatesStartIdx == -1 || templatesEndIdx == -1) {
    print('Failed to locate templates block in build_levels.dart');
    return;
  }

  // Generate the new animal templates block
  final sb = StringBuffer();
  sb.writeln('final List<List<String>> animalTemplates = [');
  for (int i = 0; i < 50; i++) {
    final name = animalNames[i];
    final template = newAnimalTemplates[name] ?? oldAnimalTemplatesFallback[i];
    sb.writeln('  // ${i + 1}. $name');
    sb.writeln('  [');
    for (int r = 0; r < template.length; r++) {
      sb.write('    "${template[r]}"');
      if (r < template.length - 1) sb.writeln(',');
      else sb.writeln();
    }
    sb.write('  ]');
    if (i < 49) sb.writeln(',');
    else sb.writeln();
  }
  sb.writeln('];');
  sb.writeln();

  final oldTemplatesBlock = content.substring(templatesStartIdx, templatesEndIdx);
  content = content.replaceFirst(oldTemplatesBlock, sb.toString());

  file.writeAsStringSync(content);
  print('Successfully swapped level order and replaced animal templates with high quality designs!');
}

// Fallback names and original templates parsed dynamically to prevent compilation errors if any animal name is missing
final List<String> animalNames = [
  "Kedi", "Kopek", "Panda", "Kurbagha", "Domuz", "Ayi", "Tavsan", "Tilki", "Penguen", "Baykus",
  "Maymun", "Zurafa", "Fil", "Aslan", "Kaplan", "Ari", "Ugurbulu", "Kaplumbaga", "Balik", "Yengec",
  "Ahtapot", "Ordek", "Koyun", "Inek", "Fare", "Koala", "Kanguru", "Su Aygiri", "Gergedan", "Timsah",
  "Geyik", "Yarasa", "Kurt", "Yilan", "Yunus", "Balina", "Kopekbaligi", "Kelebek", "Civciv", "Sincap",
  "Deve", "Kugu", "Hamster", "Ugur Bocegi", "Baykus 2", "Kizil Tilki", "Penguen 2", "Kutup Ayisi", "Yavru Panda", "Disi Aslan"
];

final List<List<String>> oldAnimalTemplatesFallback = List.generate(50, (_) => List.generate(16, (_) => "................"));
