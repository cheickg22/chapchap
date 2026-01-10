<?php

namespace App\Base\Filters\Admin;

use App\Base\Libraries\QueryFilter\FilterContract;
use Illuminate\Http\Request;
use Carbon\Carbon;
/**
 * Test filter to demonstrate the custom filter usage.
 * Delete later.
 */
class RequestEnquiryFilter implements FilterContract
{

    /**
     * The available filters.
     *
     * @return array
     */
    public function filters()
    {
        return [
            'converted_as_ride',
        ];
    }

    /**
    * Default column to sort.
    *
    * @return string
    */
    public function defaultSort()
    {
        return '-created_at';
    }

    public function converted_as_ride($builder, $value = 'all')
    {
        switch ($value) {
            case 'request_pending':
                $builder->where('converted_as_ride', 0)->where('is_cancelled', 0);
                break;
            case 'converted_as_ride':
                $builder->where('converted_as_ride', 1)->where('is_cancelled', 0);
                break;     
            case 'cancelled':
            $builder->where('is_cancelled', 1)->where('converted_as_ride', 0);
            break;             
        }
    }


}
