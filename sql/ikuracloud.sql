-- --------------------------------------------------------
-- ホスト:                          127.0.0.1
-- サーバーのバージョン:                   5.5.56-MariaDB - MariaDB Server
-- サーバー OS:                      Linux
-- HeidiSQL バージョン:               9.4.0.5125
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- IkuraCloud のデータベース構造をダンプしています
CREATE DATABASE IF NOT EXISTS `IkuraCloud` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `IkuraCloud`;

--  テーブル IkuraCloud.scaleouts の構造をダンプしています
CREATE TABLE IF NOT EXISTS `scaleouts` (
  `ScaleOutID` int(8) unsigned NOT NULL COMMENT 'スケールアウトID',
  `MinCount` tinyint(11) unsigned NOT NULL DEFAULT '1' COMMENT 'スケールアウトの最小値(=デフォルト値)',
  `MaxCount` tinyint(11) unsigned NOT NULL DEFAULT '1' COMMENT 'スケールアウトの最大値',
  PRIMARY KEY (`ScaleOutID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- テーブル IkuraCloud.scaleouts: ~0 rows (approximately) のデータをダンプしています
/*!40000 ALTER TABLE `scaleouts` DISABLE KEYS */;
/*!40000 ALTER TABLE `scaleouts` ENABLE KEYS */;

--  テーブル IkuraCloud.users の構造をダンプしています
CREATE TABLE IF NOT EXISTS `users` (
  `UserID` int(8) unsigned zerofill NOT NULL COMMENT 'ユーザのID',
  `UserName` varchar(256) NOT NULL DEFAULT '' COMMENT 'ユーザの氏名',
  `Tel` varchar(32) NOT NULL DEFAULT '' COMMENT 'ユーザの電話番号',
  `Email` varchar(256) NOT NULL DEFAULT '' COMMENT 'ユーザのメールアドレス',
  `LoginPassword` varchar(256) NOT NULL DEFAULT '' COMMENT '管理画面にアクセスする際のパスワード(ハッシュ値かしたもの)',
  `Status` varchar(8) NOT NULL DEFAULT 'Active' COMMENT 'ユーザのステータス(Active:有効, Inactive:無効)',
  PRIMARY KEY (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- テーブル IkuraCloud.users: ~17 rows (approximately) のデータをダンプしています
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`UserID`, `UserName`, `Tel`, `Email`, `LoginPassword`, `Status`) VALUES
	(00000001, 'test1', '080', 'yy@gg', '', 'Deactive'),
	(00000002, 'test2', '090', 'yy@hh', '', 'Deactive'),
	(00000003, 'test3', '000', 'yy@jj', '', 'Deactive'),
	(00000004, 'test4', '000', 'yy@jj', '', 'Deative'),
	(00000005, 'test5', '000', 'yy@kk', '', 'Deactive'),
	(00000006, 'test6\r\n', '000', 'yy@ll', '', 'Deactive'),
	(00000007, 'test', '0120-222-2111', 'tete@test.nia.com', '', 'Active'),
	(00000008, 'Frank Sinatra', '03-1234-5678', 'fs@sinatra.com', '', 'Active'),
	(00000009, 'Nobita', '88888888', 'nobita@nobi.com', '', 'Active'),
	(00000010, 'Shizuka', '77777777', 'shizuka@minamoto.com', '', 'Active'),
	(00000011, 'Giant', '66666666', 'giant@goda.com', '', 'Active'),
	(00000012, 'hanedatest20171116', '080', 'yusuke@gg', '', 'Active'),
	(00000013, 'ikura-user', '080', 'ikura@gg', '', 'Active'),
	(00000014, 'Doraemon', '99999999', 'doraemon@fujiko.com', '', 'Active'),
	(00000015, 'Louis Armstrong', '190184-197176', 'la@neworleans.com', '', 'Active'),
	(00000016, 'Isono Sazae', '03-1234-5678', 'sazae@isono.com', '', 'Active'),
	(00000017, 'DEMO', '090-0000-1234', 'demouser@com', '', 'Active');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

--  テーブル IkuraCloud.virtual_machines の構造をダンプしています
CREATE TABLE IF NOT EXISTS `virtual_machines` (
  `id` int(8) unsigned zerofill NOT NULL AUTO_INCREMENT,
  `UserID` int(8) unsigned zerofill NOT NULL COMMENT 'VMを所有するユーザID',
  `KVMID` tinyint(8) unsigned zerofill NOT NULL COMMENT 'VMが所属するKVMサーバの番号',
  `InstanceUUID` varchar(36) NOT NULL DEFAULT '' COMMENT 'VMのUUID',
  `HostName` varchar(256) NOT NULL DEFAULT '' COMMENT 'VMのホスト名',
  `IPaddr` varchar(15) NOT NULL DEFAULT '' COMMENT 'VMのIPアドレス',
  `ExternalPort` int(8) unsigned NOT NULL COMMENT '外部からの接続に使うルータポート',
  `CPU` tinyint(3) unsigned NOT NULL COMMENT 'VMのCPU数',
  `Memory` smallint(11) unsigned NOT NULL COMMENT 'VMのメモリ(MB)',
  `Disk` mediumint(11) unsigned NOT NULL COMMENT 'VMのディスク',
  `ScaleUp` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'スケールアップ対象であれば1、対象外であれば0',
  `MinCPU` tinyint(11) unsigned DEFAULT NULL COMMENT 'VMに割り当てるCPUの最小値(=デフォルト値)',
  `MinMemory` smallint(11) unsigned DEFAULT NULL COMMENT 'VMに割り当てるメモリの最小値(=デフォルト値)',
  `MinDisk` mediumint(11) unsigned DEFAULT NULL COMMENT 'VMに割り当てるディスクサイズの最小値(=デフォルト値)',
  `MaxCPU` tinyint(11) unsigned DEFAULT NULL COMMENT 'VMに割り当てるCPUの最大値',
  `MaxMemory` mediumint(11) unsigned DEFAULT NULL COMMENT 'VMに割り当てるメモリの最大値',
  `MaxDisk` tinyint(11) unsigned DEFAULT NULL COMMENT 'VMに割り当てるディスクサイズの最大値',
  `ScaleOutID` int(8) unsigned NOT NULL DEFAULT '0' COMMENT 'スケールアウト対象であればスケールアウトID、対象外であれば0',
  `Status` varchar(16) DEFAULT NULL COMMENT 'VMのステータス(作成中:creating, 起動中:starting,  利用可能:available, 停止中:stopping, 停止:stopped, 廃止:destroyed)',
  `PublicKey` text COMMENT 'VMデフォルトユーザの公開鍵',
  PRIMARY KEY (`id`),
  KEY `ScaleOutID` (`ScaleOutID`),
  KEY `UserID` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8;

-- テーブル IkuraCloud.virtual_machines: ~50 rows (approximately) のデータをダンプしています
/*!40000 ALTER TABLE `virtual_machines` DISABLE KEYS */;
INSERT INTO `virtual_machines` (`id`, `UserID`, `KVMID`, `InstanceUUID`, `HostName`, `IPaddr`, `ExternalPort`, `CPU`, `Memory`, `Disk`, `ScaleUp`, `MinCPU`, `MinMemory`, `MinDisk`, `MaxCPU`, `MaxMemory`, `MaxDisk`, `ScaleOutID`, `Status`, `PublicKey`) VALUES
	(00000079, 00000012, 00000004, 'a8feb5a7-a4db-4983-b413-192168000202', 'hanedatest2', '192168000202', 52202, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'error_delete', 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAu8/IFIL8GY+BdwTq7263GA+BfSGiU5/GYedGKjgD58YW0/kRMzUbKQgFlOZfWAjZvYwwV/suWhRlkzltjtG9TVRILc/gnBoBCfTHbpr4Ld5fsCXg48iZPF0qz7Kx3C/cjRLt+mWkgeIiyIAitKJa6XndLJsgH72ZxCAyCeIg1wLbmOj9PwN60AnEcA9+0FPZQCux5tQaONKq2PQvWVVsOD3/YHyJtj//PsvL5Pswl5aMwwM8sw5lcIozHghWsbEXQzlK3CfhNafB0Z/m218iOL+KBTJot3yg4Wf1QSjQrLno2iPxNHYKmeA4XmCT//JDsqn3aRUeglefs1hVomSEXw== yusuk@DESKTOP-OF50QR7'),
	(00000080, 00000017, 00000003, 'a8feb5a7-a4db-4983-b413-192168000203', 'TestVM01', '192168000203', 52203, 1, 1024, 15, 0, 1, 1024, 15, 1, 1024, 15, 0, 'created', 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCHAX7CtgNWnYWFvuxJ4CqV2rE56Il6d1r4v+77SInaeAEfYgfDA2UfRn2V/JadBG/k+oDXf5CEWb+MGuKoNUzHXEWQ/VRcLJSrbVe4UmFmQmIDn4bBpprBzB6pRZFqdTBKLZWfVEONOu7DSOmsgkpQwgO0JWwPmsoguWeAXRbSwJxwbZhvTOJJ4CO2nHHoG9hZl6+rzqemFwIvn9/Ibqd6levhq+2obGZL2AqKcJktxb+/bfebcJIoWBdyEEM08yUFsOwCtP3rnMmGRDbBBnpm6CPP8YR3ATm+4nuRUesOvNh0zDVHje/PDQcMLZV/PvDXjfpp+XlKLREuq7sGEt/ a1710dk'),
	(00000081, 00000001, 00000004, 'a8feb5a7-a4db-4983-b413-192168000204', 'testvm', '192168000204', 52204, 2, 1024, 15, 0, 2, 1024, 15, 2, 1024, 15, 0, 'started', 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCHAX7CtgNWnYWFvuxJ4CqV2rE56Il6d1r4v+77SInaeAEfYgfDA2UfRn2V/JadBG/k+oDXf5CEWb+MGuKoNUzHXEWQ/VRcLJSrbVe4UmFmQmIDn4bBpprBzB6pRZFqdTBKLZWfVEONOu7DSOmsgkpQwgO0JWwPmsoguWeAXRbSwJxwbZhvTOJJ4CO2nHHoG9hZl6+rzqemFwIvn9/Ibqd6levhq+2obGZL2AqKcJktxb+/bfebcJIoWBdyEEM08yUFsOwCtP3rnMmGRDbBBnpm6CPP8YR3ATm+4nuRUesOvNh0zDVHje/PDQcMLZV/PvDXjfpp+XlKLREuq7sGEt/ a1710dk'),
	(00000082, 00000014, 00000004, 'a8feb5a7-a4db-4983-b413-192168000205', 'hostname_kasai', '192168000205', 52205, 2, 1024, 15, 0, 2, 1024, 15, 2, 1024, 15, 0, 'started', 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDcefqGs0IB5Gh54Z7PjFjud/fiqupECgdP5lOAnNXIrrgA2CE7Vl1DaRhEJEboUOVCIh6A2MZw7rPo8UgrtxX/qQAJE5Aw4vJ2121IsZmjOJrsBL0kxhRcCuTfYE3Clv/i8xXjFq48C8VJ/r6TQz3dXBfT5Q8CnvEl6BFbK+Mqy0lg4Y1EtglT6WNcpW0OpGNWJGk1KWknnWK2v9Xw2gLycn4LplMA6ktBQJ+s/8to7ZWCWT7WL3Ee8Pl24tzEjWdxycnhUD/rn20SaXNjfXclyK5S3kJKoj1OqjlywCPU1lgeqY81EUFUfAm+cezZ2SR/0OIkWsjEzDnm3fZuXTfB Yosuke@kasaiyousuke-no-MacBook.local'),
	(00000083, 00000000, 00000001, 'a8feb5a7-a4db-4983-b413-192168000206', 'demo2', '192168000206', 52206, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'deleted', 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA42AqdfKwcLiWy6m/HM9LOKnajfqPgiH054N1UshB08k+mP8iKfBjG5Mn9eIwUnDqAfH/JAD3OfM7S6Dd5wNd++fL6Zoh9PBGQHKYGUAPetCSyXmEJuIrHstCzeZfrLABBG/JORgqkLIrcC6+qHGRS5g/BlPAILNdPi3pXrLVO/qaOZ1ZA3nEFDTjGwvGbyHiKOsodioGOonMOQD6P8KAOgZ3N/pSchAiHxl7CiCA8sBkgUWnvTmF2i9Xr2rnXtf8wnmdn4SKzfQUQN37ACN/MN41Wz7l6Bs00DgUXQMhbn/IWExiZJq4AbbfY0f4dPyaynjpwwKlkpt8Fsjis2ISTQ== yusuk@DESKTOP-OF50QR7'),
	(00000084, 00000000, 00000004, 'a8feb5a7-a4db-4983-b413-192168000207', 'WonderfulWorld', '192168000207', 52207, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'deleted', 'What A Wonderful World!What A Wonderful World!What A Wonderful World!What A Wonderful World!What A Wonderful World!What A Wonderful World!What A Wonderful World!What A Wonderful World!What A Wonderful World!What A Wonderful World!'),
	(00000085, 00000000, 00000001, 'a8feb5a7-a4db-4983-b413-192168000201', 'DokodemoDoor', '192168000201', 52201, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'deleted', 'DokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoorDokodemoDoor'),
	(00000086, 00000000, 00000003, 'a8feb5a7-a4db-4983-b413-192168000208', 'Pocket', '192168000208', 52208, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'deleted', 'PocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocketPocket'),
	(00000087, 00000000, 00000004, 'a8feb5a7-a4db-4983-b413-192168000209', 'mikawaya', '192168000209', 52209, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'deleted', 'mikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawayamikawaya'),
	(00000089, 00000000, 00000003, 'a8feb5a7-a4db-4983-b413-192168000211', 'test4', '192168000211', 52211, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'deleted', 'tetete'),
	(00000090, 00000000, 00000003, 'a8feb5a7-a4db-4983-b413-192168000212', 'test5', '192168000212', 52212, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'deleted', 'ttt'),
	(00000091, 00000000, 00000004, 'a8feb5a7-a4db-4983-b413-192168000213', 'saifuwasureta', '192168000213', 52213, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'deleted', 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDO7TI5PCQ1bvCcoVp/+07rzStPsI17l9dQtnWQVEs18h2wrvqzV3rvZcdrfoYSTXleC5FG8oSAEArJMLppVEqKryrn8u1T1+AhHpXaJ+BWCAtYJJmyBR5Kt0Drog7xXPPew/HVDhZCr2hqClfYWex5dtukm+wATAF0qbRjvEZt7JUgAaPsaFECoN56hIPMrAvoKhSsfzele2+U9wjXAha2554ZW1zMjW+DBHYseio+cVYjLhkpYpcdlwze3DpijTjnByvzBjxiNNbKpeicBlWtalAUCZmr4+swrJvnsOCyr1Lu25+NVtJ33Y3U7rFbe+f1mJF14/O/G/YGi0/kV9Kf photomotch@mbp2016late.local'),
	(00000092, 00000000, 00000004, 'a8feb5a7-a4db-4983-b413-192168000214', 'test1test2test3test4test5test6', '192168000214', 52214, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'deleted', 'keykey'),
	(00000093, 00000000, 00000001, 'a8feb5a7-a4db-4983-b413-192168000215', 'tetete', '192168000215', 52215, 3, 1536, 15, 0, 3, 1536, 15, 3, 1536, 15, 0, 'deleted', 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCHAX7CtgNWnYWFvuxJ4CqV2rE56Il6d1r4v+77SInaeAEfYgfDA2UfRn2V/JadBG/k+oDXf5CEWb+MGuKoNUzHXEWQ/VRcLJSrbVe4UmFmQmIDn4bBpprBzB6pRZFqdTBKLZWfVEONOu7DSOmsgkpQwgO0JWwPmsoguWeAXRbSwJxwbZhvTOJJ4CO2nHHoG9hZl6+rzqemFwIvn9/Ibqd6levhq+2obGZL2AqKcJktxb+/bfebcJIoWBdyEEM08yUFsOwCtP3rnMmGRDbBBnpm6CPP8YR3ATm+4nuRUesOvNh0zDVHje/PDQcMLZV/PvDXjfpp+XlKLREuq7sGEt/ a1710dk'),
	(00000094, 00000013, 00000004, 'a8feb5a7-a4db-4983-b413-192168000216', 'TestVM01', '192168000216', 52216, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'started', 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCHAX7CtgNWnYWFvuxJ4CqV2rE56Il6d1r4v+77SInaeAEfYgfDA2UfRn2V/JadBG/k+oDXf5CEWb+MGuKoNUzHXEWQ/VRcLJSrbVe4UmFmQmIDn4bBpprBzB6pRZFqdTBKLZWfVEONOu7DSOmsgkpQwgO0JWwPmsoguWeAXRbSwJxwbZhvTOJJ4CO2nHHoG9hZl6+rzqemFwIvn9/Ibqd6levhq+2obGZL2AqKcJktxb+/bfebcJIoWBdyEEM08yUFsOwCtP3rnMmGRDbBBnpm6CPP8YR3ATm+4nuRUesOvNh0zDVHje/PDQcMLZV/PvDXjfpp+XlKLREuq7sGEt/ a1710dk'),
	(00000095, 00000013, 00000001, 'a8feb5a7-a4db-4983-b413-192168000217', 'TESTVM02', '192168000217', 52217, 2, 1024, 15, 0, 2, 1024, 15, 2, 1024, 15, 0, 'started', 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCHAX7CtgNWnYWFvuxJ4CqV2rE56Il6d1r4v+77SInaeAEfYgfDA2UfRn2V/JadBG/k+oDXf5CEWb+MGuKoNUzHXEWQ/VRcLJSrbVe4UmFmQmIDn4bBpprBzB6pRZFqdTBKLZWfVEONOu7DSOmsgkpQwgO0JWwPmsoguWeAXRbSwJxwbZhvTOJJ4CO2nHHoG9hZl6+rzqemFwIvn9/Ibqd6levhq+2obGZL2AqKcJktxb+/bfebcJIoWBdyEEM08yUFsOwCtP3rnMmGRDbBBnpm6CPP8YR3ATm+4nuRUesOvNh0zDVHje/PDQcMLZV/PvDXjfpp+XlKLREuq7sGEt/ a1710dk'),
	(00000096, 00000013, 00000001, 'a8feb5a7-a4db-4983-b413-192168000218', 'TESTVM03', '192168000218', 52218, 3, 1536, 15, 0, 3, 1536, 15, 3, 1536, 15, 0, 'started', 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCHAX7CtgNWnYWFvuxJ4CqV2rE56Il6d1r4v+77SInaeAEfYgfDA2UfRn2V/JadBG/k+oDXf5CEWb+MGuKoNUzHXEWQ/VRcLJSrbVe4UmFmQmIDn4bBpprBzB6pRZFqdTBKLZWfVEONOu7DSOmsgkpQwgO0JWwPmsoguWeAXRbSwJxwbZhvTOJJ4CO2nHHoG9hZl6+rzqemFwIvn9/Ibqd6levhq+2obGZL2AqKcJktxb+/bfebcJIoWBdyEEM08yUFsOwCtP3rnMmGRDbBBnpm6CPP8YR3ATm+4nuRUesOvNh0zDVHje/PDQcMLZV/PvDXjfpp+XlKLREuq7sGEt/ a1710dk'),
	(00000097, 00000013, 00000003, 'a8feb5a7-a4db-4983-b413-192168000219', 'test', '192168000219', 52219, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'created', 'test'),
	(00000098, 00000013, 00000004, 'a8feb5a7-a4db-4983-b413-192168000220', 'demo1', '192168000220', 52220, 1, 512, 15, 0, 1, 512, 15, 1, 512, 15, 0, 'started', 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA4IsA6mXI5urjQ4QiepaKOGzBMjY1Az24YfmnHkqr0vY4vKH5haAiQ+U0xFp0LPa6MsEJ4G1TrO3CrWyquwEUXoU4dbwBwalmThVLtIq73CEwuKewW7/XaICRy6yAQACJmQVd/HW8cdRl4cwtEhTcAKGuQrFWpR356gjzDP0P71EQyRYecRGPTu1zU/YJBjHaBxgg6+4wr5vaEIvL2QcUbMYzF7o1M6qcbDbyp1raftIjqGYxbBK2CRbaSL2p28ItOVL+e6nJ4TxTWHq9+G69FsHeIAxOg7tszDE5p3LuR7GK83pGvsJONfdQot4t5o8bhAfcjeB9RlISDP2ck0JpVQ== yusuk@DESKTOP-OF50QR7'),
	(00000099, 00000000, 00000000, '', '', '192168000221', 52221, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000100, 00000000, 00000000, '', '', '192168000222', 52222, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000101, 00000000, 00000000, '', '', '192168000223', 52223, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000102, 00000000, 00000000, '', '', '192168000224', 52224, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000103, 00000000, 00000000, '', '', '192168000225', 52225, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000104, 00000000, 00000000, '', '', '192168000226', 52226, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000105, 00000000, 00000000, '', '', '192168000227', 52227, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000106, 00000000, 00000000, '', '', '192168000228', 52228, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000107, 00000000, 00000000, '', '', '192168000231', 52231, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000108, 00000000, 00000000, '', '', '192168000232', 52232, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000109, 00000000, 00000000, '', '', '192168000229', 52229, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000110, 00000000, 00000000, '', '', '192168000230', 52230, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000111, 00000000, 00000000, '', '', '192168000233', 52233, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000112, 00000000, 00000000, '', '', '192168000234', 52234, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000113, 00000000, 00000000, '', '', '192168000235', 52235, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000114, 00000000, 00000000, '', '', '192168000236', 52236, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000115, 00000000, 00000000, '', '', '192168000237', 52237, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000116, 00000000, 00000000, '', '', '192168000238', 52238, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000117, 00000000, 00000000, '', '', '192168000239', 52239, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000118, 00000000, 00000000, '', '', '192168000210', 52210, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000119, 00000000, 00000000, '', '', '192168000240', 52240, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000120, 00000000, 00000000, '', '', '192168000241', 52241, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000121, 00000000, 00000000, '', '', '192168000242', 52242, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000122, 00000000, 00000000, '', '', '192168000243', 52243, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000123, 00000000, 00000000, '', '', '192168000244', 52244, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000124, 00000000, 00000000, '', '', '192168000245', 52245, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000125, 00000000, 00000000, '', '', '192168000246', 52246, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000126, 00000000, 00000000, '', '', '192168000247', 52247, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000127, 00000000, 00000000, '', '', '192168000248', 52248, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000128, 00000000, 00000000, '', '', '192168000249', 52249, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL),
	(00000129, 00000000, 00000000, '', '', '192168000250', 52250, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL);
/*!40000 ALTER TABLE `virtual_machines` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
