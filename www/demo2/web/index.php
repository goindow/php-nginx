<?php

    #$manager = new MongoDB\Driver\Manager("mongodb://hyb:123456@47.111.0.166:27017/test");
    $manager = new MongoDB\Driver\Manager("mongodb://hyb:123456@10.0.235.231:27017/test");

    $query = new MongoDB\Driver\Query([]);
    
    $cursor = $manager->executeQuery('test.user', $query);

    foreach ($cursor as $document) {
        print_r($document);
    }
