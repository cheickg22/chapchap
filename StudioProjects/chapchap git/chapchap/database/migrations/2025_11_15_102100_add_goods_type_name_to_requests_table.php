<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddGoodsTypeNameToRequestsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (Schema::hasTable('requests')) {
            if (!Schema::hasColumn('requests', 'goods_type_name')) {
                Schema::table('requests', function (Blueprint $table) {
                    $table->string('goods_type_name')->after('goods_type_id')->nullable();
                });
            }
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        if (Schema::hasTable('requests')) {
            if (Schema::hasColumn('requests', 'goods_type_name')) {
                Schema::table('requests', function (Blueprint $table) {
                    $table->dropColumn('goods_type_name');
                });
            }
        }
    }
}
