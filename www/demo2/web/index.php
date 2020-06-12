<?php

    #$manager = new MongoDB\Driver\Manager("mongodb://hyb:123456@47.111.0.166:27017/test");
    $manager = new MongoDB\Driver\Manager("mongodb://hyb:123456@192.168.0.102:27017/test");

    $query = new MongoDB\Driver\Query([]);
    
    $cursor = $manager->executeQuery('test.user', $query);

    foreach ($cursor as $document) {
        print_r($document);
    }
